From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 5/6] cxgb4: Add main driver file and driver Makefile
Date: Wed, 31 Mar 2010 17:19:21 -0700
Message-ID: <4BB3E689.4050001@chelsio.com>
References: <1269975142-30896-5-git-send-email-dm@chelsio.com>	<1269975142-30896-6-git-send-email-dm@chelsio.com>	<20100330141904.5236fe44@nehalam> <20100330.225042.107712654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15688 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab0DAAT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 20:19:28 -0400
In-Reply-To: <20100330.225042.107712654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 30 Mar 2010 14:19:04 -0700
> 
>> On Tue, 30 Mar 2010 10:52:21 -0800
>> Dimitris Michailidis <dm@chelsio.com> wrote:
>>
>>> +static struct cxgb4_proc_entry proc_files[] = {
>>> +#ifdef CONFIG_PROC_FS
>>> +	{ "l2t", 0444, ADAP_NEED_L2T, 0, &t4_l2t_proc_fops },
>>> +#endif
>>> +	{ "lb_stats", 0444, 0, 0, &lb_stats_proc_fops },
>>> +	{ "path_mtus", 0644, 0, 0, &mtutab_proc_fops },
>>> +	{ "qstats", 0444, 0, 0, &sge_stats_proc_fops },
>>> +	{ "rss", 0444, 0, 0, &rss_proc_fops },
>>> +	{ "tcp_stats", 0444, 0, 0, &tcp_stats_proc_fops },
>>> +	{ "tids", 0444, ADAP_NEED_OFLD, 0, &tid_info_proc_fops },
>>> +	{ "tp_err_stats", 0444, 0, 0, &tp_err_stats_proc_fops },
>>> +	{ "trace0", 0644, 0, 0, &mps_trc_proc_fops },
>>> +	{ "trace1", 0644, 0, 1, &mps_trc_proc_fops },
>>> +	{ "trace2", 0644, 0, 2, &mps_trc_proc_fops },
>>> +	{ "trace3", 0644, 0, 3, &mps_trc_proc_fops },
>>> +	{ "uld", 0444, 0, 0, &uld_proc_fops },
>>> +};
>>> +
>> Do you really need this large number of /proc files.
>> It creates another stable API to worry about.  If it is just for
>> debugging move it to debugfs, or better yet just drop it.
> 
> I also find this a bit too much.
> 
> We have all kinds of ways to export whatever statistics you
> want.  In particular we have ethtool stats of which you
> can have as many as you wish.
> 
> If necessary, we could add a feature to define "views" of ethtool
> stats so that we can have domains of driver specific statistics if the
> problem is that you don't want all of these debugging stats to clutter
> up the "main" ethtool stats.

It wasn't a concern with having too many ethtool stats that led to the use 
of proc, rather it was that most of this information isn't associated with 
netdevs.  Let me give an example.  Like most virtualized NICs this device 
contains a switch.  Some of the switch statistics are provided in the proc 
files.  While they are statistics, logically they are not associated with 
any of the netdevs.  If ethtool were to be extended so that the specified 
interface would access the underlying HW to get information possibly 
unrelated to the interface personally I'd be OK with that, I am just 
pointing out what kind of extension we are talking about.

Also some of the files here aren't statistics but report other functionality 
  of the device, usually also not tied to netdevs (e.g., the trace* files 
are again related to the switch).

So, I propose getting rid of 3-4 of these files that are of lesser value and 
moving the rest to debugfs for now.  If some alternative through ethtool or 
something becomes available I can get rid of anything that can be handled 
through a more general facility.  Would that be acceptable?
