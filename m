From: "ustc.mail" <backyes@mail.ustc.edu.cn>
Subject: [PATCH] about net/core/pktgen.c module.
Date: Tue, 3 Aug 2010 23:20:17 +0800
Message-ID: <AANLkTim7ZhGGgE9TJsu1m5=fD743meN12V5Ywn_9Cyaq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: robert.olsson@its.uu.se
To: robert@herjulf.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ustc.edu.cn ([202.38.64.46]:33791 "HELO ustc.edu.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756899Ab0HCP2I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 11:28:08 -0400
Received: by qyk7 with SMTP id 7so781770qyk.19
        for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 08:20:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I find that there is a bug in the pktgen kernel packet generator. It's
my first time to add a patch, so welcome to give me suggestion about
patch work.

description: the bug makes the first generated packets (one or more
which depend on the configuration from usespace script.)enter to the
same NIC queue of multi-queue NIC for the wrong position of
mod_cur_headers(pkt_dev) call while building the IPV4 and IPV6
skb_buff.
kernel version: linux-2.6.33.3
file: linux-2.6.33.3/net/core/pktgen.c
result: while setting skb_clone more than one, specially for a
considerable number, the multiqueue function is not efficient for its
wrong queue_map value.
patch as following:
--- pktgen.c	2010-08-03 22:46:55.001682745 +0800
+++ pktgen.patch.c	2010-08-03 22:48:03.367409102 +0800
@@ -2567,8 +2567,8 @@
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
-	queue_map =3D pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
+	queue_map =3D pkt_dev->cur_queue_map;

 	datalen =3D (odev->hard_header_len + 16) & ~0xf;
 	skb =3D __netdev_alloc_skb(odev,
@@ -2913,8 +2913,8 @@
 	/* Update any of the values, used when we're incrementing various
 	 * fields.
 	 */
-	queue_map =3D pkt_dev->cur_queue_map;
 	mod_cur_headers(pkt_dev);
+	queue_map =3D pkt_dev->cur_queue_map;

 	skb =3D __netdev_alloc_skb(odev,
 				 pkt_dev->cur_pkt_size + 64
--------------------------------------patch
end-------------------------------------------------
Best regards!
from backyes
---------------------------------------reply
end-------------------------------------------------
On Tue, Aug 3, 2010 at 10:30 PM, ustc.mail <backyes@mail.ustc.edu.cn> w=
rote:
> Thanks for your reply!
> It's my pleasure to patch it.
> -Yanfei
>
> On Tue, Aug 3, 2010 at 7:44 PM, <robert@herjulf.net> wrote:
>>
>> > Dear robert, I am doing some research on the
>> >pktgen.c implementation. While reading the source code, I find some
>> >doubts about cur->cur_queue_map for multiqueue NIC . =A0The followi=
ng
>> >code is from pktgen.c in kernel 2.6.33.3.=A0 =A0For line 2919 and l=
ine
>> >2920, the first generated packets is sent to same queue of NIC for
>> >every thread. Because the the first generated packets is sent while
>> >the cur_queue_map is not setted yet.=A0 =A0"reverse the two line" i=
s OK.
>> >Am I right?
>>
>> Right first time we're using queue_map that's not been set by
>> set_cur_queue_map(pkt_dev);
>>
>> =A0 =A0 =A0 =A0queue_map =3D pkt_dev->cur_queue_map;
>> =A0 =A0 =A0 =A0mod_cur_headers(pkt_dev);
>>
>> Can you make a patch and submit to netdev?
>>
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0--ro
>>
>
>

