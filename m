From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15684] New: Netlink is notifying
 RTNLGRP_IPV6_IFADDR instead of RTNLGRP_IPV6_IFINFO
Date: Mon, 5 Apr 2010 12:54:31 -0700
Message-ID: <20100405125431.14c67afa.akpm@linux-foundation.org>
References: <bug-15684-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, eduardo.panisset@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41379 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756069Ab0DET4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 15:56:21 -0400
In-Reply-To: <bug-15684-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 2 Apr 2010 18:35:14 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15684
> 
>            Summary: Netlink is notifying RTNLGRP_IPV6_IFADDR instead of
>                     RTNLGRP_IPV6_IFINFO
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.28-2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: eduardo.panisset@gmail.com
>         Regression: No
> 
> 
> It seems the inet6_ifinfo_notify function placed in "net/ipv6/addrconf.c" is
> notifying the wrong netlink group (RTNLGRP_IPV6_IFADDR) with ifinfo structure.
> 
> So I suggest the correction below (RTNLGRP_IPV6_IFINFO takes the place of
> RTNLGRP_IPV6_IFADDR):
> 
> void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
> {
> 
> ...
> 
>    err = rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFINFO, NUL, GFP_ATOMIC);
> ...
> 
> errout:
>    if (err < 0)
>       rtnl_set_sk_err(net, RTNLGRP_IPV6_IFINFO, err);
> }
> 

