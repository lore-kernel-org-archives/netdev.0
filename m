From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next v2] ipv6: Do not iterate over all interfaces
 when finding source address on specific interface.
Date: Mon, 13 Jul 2015 15:32:18 +0900
Message-ID: <55A35B72.2060009@miraclelinux.com>
References: <559F7B27.6030205@miraclelinux.com> <20150710.231943.1262522002810525503.davem@davemloft.net> <CAAedzxpMP-DmKOy-BfQkReGWmbujGqM_JsdmYtcuxVDqAdXNKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030902070301090004050202"
Cc: hideaki.yoshifuji@miraclelinux.com,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36858 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbGMGcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 02:32:23 -0400
Received: by pdjr16 with SMTP id r16so57379655pdj.3
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2015 23:32:22 -0700 (PDT)
In-Reply-To: <CAAedzxpMP-DmKOy-BfQkReGWmbujGqM_JsdmYtcuxVDqAdXNKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030902070301090004050202
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Hi,

Erik Kline wrote:
> Hmm, when I run a UML linux with this patch (which, I'm ashamed to
> say, I failed to do before) I get these kinds of errors:
> 
>     unregister_netdevice: waiting for <TAPdevice> to become free.
> Usage count = 1
>     unregister_netdevice: waiting for <TAPdevice> to become free.
> Usage count = 1
> 
> Perhaps they're unrelated... I'm still investigating.

Would you test attached patch please?

--yoshfuji

> 
> On 11 July 2015 at 15:19, David Miller <davem@davemloft.net> wrote:
>> From: YOSHIFUJI Hideaki/吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
>> Date: Fri, 10 Jul 2015 16:58:31 +0900
>>
>>> If outgoing interface is specified and the candidate address is
>>> restricted to the outgoing interface, it is enough to iterate
>>> over that given interface only.
>>>
>>> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
>>> Acked-by: Erik Kline <ek@google.com>
>>
>> Applied, thanks!

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION

--------------030902070301090004050202
Content-Type: text/x-diff;
 name="0001-ipv6-Avoid-NULL-pointer-dereference-in-__ipv6_dev_ge.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ipv6-Avoid-NULL-pointer-dereference-in-__ipv6_dev_ge.pa";
 filename*1="tch"

>From 38c5a10a5876ea47766ffc05b5a131a210d6e1aa Mon Sep 17 00:00:00 2001
From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Date: Mon, 13 Jul 2015 15:23:02 +0900
Subject: [PATCH] ipv6: Avoid NULL pointer dereference in
 __ipv6_dev_get_saddr().

Commit 9131f3de2 ("ipv6: Do not iterate over all interfaces when
finding source address on specific interface.") introduced
possible NULL pointer dereference if outgoing device is
specified.

Fixes: 9131f3de24db4dc12199aede7d931e6703e97f3b ("ipv6: Do not
	iterate over all interfaces when finding source address
	on specific interface.")
Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
---
 net/ipv6/addrconf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4ab74d5..50ad476 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1480,7 +1480,8 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 	}
 
 	if (use_oif_addr) {
-		__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores);
+		if (idev)
+			__ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, scores);
 	} else {
 		for_each_netdev_rcu(net, dev) {
 			idev = __in6_dev_get(dev);
-- 
1.9.1


--------------030902070301090004050202--
