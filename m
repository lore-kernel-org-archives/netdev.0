From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: delete protocol when cleanup
Date: Tue, 18 Nov 2014 11:14:15 -0800
Message-ID: <1416338055.14060.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <546B20F8.6010806@cn.fujitsu.com>
	 <CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:36795 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbaKRTOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 14:14:18 -0500
Received: by mail-ie0-f172.google.com with SMTP id ar1so10084407iec.3
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 11:14:17 -0800 (PST)
In-Reply-To: <CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-18 at 10:56 -0800, Cong Wang wrote:
> On Tue, Nov 18, 2014 at 2:35 AM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
> >
> > pim6_protocol was added when initiation, but it not deleted.
> >
> > Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

...

> Looks like rtnl_unregister() is missing as well.

Is it really worth bothering ?

May I remind you we took the decision one year ago to not bother about
removing ipv6 module.

commit 8ce440610357b77587433d0df647cea69a6890a8
Author: Cong Wang <amwang@redhat.com>
Date:   Sat Sep 21 11:12:21 2013 +0800

    ipv6: do not allow ipv6 module to be removed
    
    There was some bug report on ipv6 module removal path before.
    Also, as Stephen pointed out, after vxlan module gets ipv6 support,
    the ipv6 stub it used is not safe against this module removal either.
    So, let's just remove inet6_exit() so that ipv6 module will not be
    able to be unloaded.
    
    Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
    Cc: Stephen Hemminger <stephen@networkplumber.org>
    Cc: David S. Miller <davem@davemloft.net>
    Signed-off-by: Cong Wang <amwang@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
