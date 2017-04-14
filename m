From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v2 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Thu, 13 Apr 2017 18:50:42 -0700
Message-ID: <20170413185042.0e69cb71@cakuba.lan>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
        <1492069701-20772-6-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:18702 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751260AbdDNBu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 21:50:59 -0400
In-Reply-To: <1492069701-20772-6-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Thu, 13 Apr 2017 17:48:18 +1000, Gavin Shan wrote:
> This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
> packets sent and received over all packages and channels. It's useful
> to diagnose NCSI problems, especially when NCSI packages and channels
> aren't probed properly. The statistics can be gained from debugfs file
> as below:
> 
>  # cat /sys/kernel/debug/ncsi/eth0/stats
> 
>  CMD          OK       TIMEOUT  ERROR
>  =======================================
>  CIS          32       29       0
>  SP           10       7        0
>  DP           17       14       0
>  EC           1        0        0
>  ECNT         1        0        0
>  AE           1        0        0
>  GLS          11       0        0
>  SMA          1        0        0
>  EBF          1        0        0
>  GVI          2        0        0
>  GC           2        0        0
> 
>  RSP          OK       TIMEOUT  ERROR
>  =======================================
>  CIS          3        0        0
>  SP           3        0        0
>  DP           2        0        1
>  EC           1        0        0
>  ECNT         1        0        0
>  AE           1        0        0
>  GLS          11       0        0
>  SMA          1        0        0
>  EBF          1        0        0
>  GVI          0        0        2
>  GC           2        0        0
> 
>  AEN          OK       TIMEOUT  ERROR
>  =======================================
> 
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>

I'm not familiar with NC-SI but these look like some standard stats.
Would it make sense to provide a proper netlink API for them?

[...]
> +#ifdef CONFIG_NET_NCSI_DEBUG
> +		ndp->stats.aen[h->type][NCSI_PKT_STAT_ERROR]++;
> +#endif

In any case, did you consider creating a macro or inline helper to
limit the number of #ifdefs?
