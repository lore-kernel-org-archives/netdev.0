From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] cxgb4: Add main driver file and driver Makefile
Date: Tue, 30 Mar 2010 22:50:42 -0700 (PDT)
Message-ID: <20100330.225042.107712654.davem@davemloft.net>
References: <1269975142-30896-5-git-send-email-dm@chelsio.com>
	<1269975142-30896-6-git-send-email-dm@chelsio.com>
	<20100330141904.5236fe44@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33646
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757144Ab0CaFul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 01:50:41 -0400
In-Reply-To: <20100330141904.5236fe44@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 30 Mar 2010 14:19:04 -0700

> On Tue, 30 Mar 2010 10:52:21 -0800
> Dimitris Michailidis <dm@chelsio.com> wrote:
> 
>> +static struct cxgb4_proc_entry proc_files[] = {
>> +#ifdef CONFIG_PROC_FS
>> +	{ "l2t", 0444, ADAP_NEED_L2T, 0, &t4_l2t_proc_fops },
>> +#endif
>> +	{ "lb_stats", 0444, 0, 0, &lb_stats_proc_fops },
>> +	{ "path_mtus", 0644, 0, 0, &mtutab_proc_fops },
>> +	{ "qstats", 0444, 0, 0, &sge_stats_proc_fops },
>> +	{ "rss", 0444, 0, 0, &rss_proc_fops },
>> +	{ "tcp_stats", 0444, 0, 0, &tcp_stats_proc_fops },
>> +	{ "tids", 0444, ADAP_NEED_OFLD, 0, &tid_info_proc_fops },
>> +	{ "tp_err_stats", 0444, 0, 0, &tp_err_stats_proc_fops },
>> +	{ "trace0", 0644, 0, 0, &mps_trc_proc_fops },
>> +	{ "trace1", 0644, 0, 1, &mps_trc_proc_fops },
>> +	{ "trace2", 0644, 0, 2, &mps_trc_proc_fops },
>> +	{ "trace3", 0644, 0, 3, &mps_trc_proc_fops },
>> +	{ "uld", 0444, 0, 0, &uld_proc_fops },
>> +};
>> +
> 
> Do you really need this large number of /proc files.
> It creates another stable API to worry about.  If it is just for
> debugging move it to debugfs, or better yet just drop it.

I also find this a bit too much.

We have all kinds of ways to export whatever statistics you
want.  In particular we have ethtool stats of which you
can have as many as you wish.

If necessary, we could add a feature to define "views" of ethtool
stats so that we can have domains of driver specific statistics if the
problem is that you don't want all of these debugging stats to clutter
up the "main" ethtool stats.
