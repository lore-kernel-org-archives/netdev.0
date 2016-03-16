From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v3 1/2] RDS: TCP: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Wed, 16 Mar 2016 07:06:06 -0400
Message-ID: <20160316110606.GA21307@oracle.com>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
 <5c18f6bdde99628e486d63a071c256d1be036c28.1458064902.git.sowmini.varadhan@oracle.com>
 <56E93596.90503@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	santosh.shilimkar@oracle.com, eric.dumazet@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17577 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966451AbcCPLGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 07:06:20 -0400
Content-Disposition: inline
In-Reply-To: <56E93596.90503@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/16/16 11:29), Hannes Frederic Sowa wrote:
> 
> Normally we kmemdup a table per netns and update its data pointer,
> so we can reuse the proc_doint_minmax functions.

I actually thought of doing a separate kzalloc per netns, 
but it seemed like it would be a lot of memory bloat, when really,
all I want is just the per-netns data.

I could go and duplicate the whole table, but is there a significant
benefit to that, or some bad bug with this approach? 

One dubious (yes, I know, "solution looking for problem" category)
benefit is that this hack allows me to have both global, and per netns,
tunables... plus the reduced memory footprint (latter is probably
more interesting than former?)

> >+	rtn->rds_tcp_sysctl = register_net_sysctl(net, "net/rds/tcp",
> >+						  rds_tcp_sysctl_table);
> 
> You should add proper error handling here?

Agree, I will send this out in the next rev.

> >+	rtn->sndbuf_size = max_t(u32, user_atoi(buffer, *lenp) * 2,
> >+				 SOCK_MIN_SNDBUF);
> 
> user_atoi does return negative error values (as you implemented it),
> I think you should check before, otherwise the signed to unsigned
> conversion can cause huge memory allocations.

yes, good catch, that will have to be split into two lines. Shall
be fixing this in v4.

> Why actually implement user_atoi?

errhm. cut/paste from other drivers that do this. I needed to
do the copy_from_user() + kstrtoul, and user_atoi had some 
additional checks that seemed useful. 

--Sowmini
