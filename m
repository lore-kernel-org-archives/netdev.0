From: jamal <hadi@cyberus.ca>
Subject: Re: tc ipt action bug
Date: Sun, 04 Jan 2009 09:48:27 -0500
Message-ID: <1231080507.3345.7.camel@dogo.mojatatu.com>
References: <495FCAA8.1000005@pisem.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yawhen Kasarzhewski <yevg@pisem.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:43253 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbZADOtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 09:49:39 -0500
Received: by ewy10 with SMTP id 10so7465448ewy.13
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2009 06:49:36 -0800 (PST)
In-Reply-To: <495FCAA8.1000005@pisem.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upgrade to latest iproute2 - probably from git tree which should fix
this in the following commit:
-----

commit 53c017880b311d7d68926109d4248c900286f6b7
Author: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Date:   Mon Dec 24 11:51:11 2007 -0500

    iptables compatiablity
    
    New iptables 1.4.0 has some library names changed from libipt to
libxt.
    It is prefferable also to open libxt_ first, as newer "style".
    
    Signed-off-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
    Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
-------

cheers,
jamal

On Sat, 2009-01-03 at 22:29 +0200, Yawhen Kasarzhewski wrote:
> iproute is still using old iptables so failing to work with new xt_tables:
> 
> warp:~# tc filter add dev ppp0 parent ffff: protocol ip prio 10 u32 \
>  >   match u32 0 0 flowid 1:1 \
>  >   action ipt -j MARK --set-mark 1 \
>  >   action mirred egress redirect dev ifb0
> /lib/iptables/libipt_mark.so: cannot open shared object file: No such 
> file or directory
> failed to find target MARK
> warp:~# find /lib -name "*mark.so"
> /lib/ebtables/libebt_mark.so
> /lib/xtables/libxt_connmark.so
> /lib/xtables/libxt_mark.so
> warp:~# iptables -V
> iptables v1.4.1.1
> warp:~# tc -V
> tc utility, iproute2-ss080725
> warp:~# uname -a
> Linux warp 2.6.26 #2 Sun Jul 27 21:06:55 EEST 2008 i686 GNU/Linux
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

