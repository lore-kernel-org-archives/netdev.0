From: "Murat Sezgin" <msezgin@codeaurora.org>
Subject: kernel panic in pppoe_release
Date: Thu, 3 Sep 2015 12:14:32 -0700
Message-ID: <006f01d0e67c$c3d53f10$4b7fbd30$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46984 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbbICTOd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 15:14:33 -0400
Received: from MSEZGIN (qf-scl1nat.qualcomm.com [207.114.132.30])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: msezgin@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id E9ABC141880
	for <netdev@vger.kernel.org>; Thu,  3 Sep 2015 19:14:32 +0000 (UTC)
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have already sent this email to linux-ppp group, but I have not recei=
ved
any response yet. So, I want to send it to this group as well, because =
it is
most likely a netdev issue in pppoe kernel driver.

I see the bug in the below email discussion on the kernel that we are
currently using (3.4.103) with our openwrt distribution.

https://www.mail-archive.com/netdev@vger.kernel.org/msg70367.html

I did some debug on this and I see that the ref count of the po->pppoe_=
dev
doesn=92t go to zero before releasing it with dev_put() and set its val=
ue to
NULL.

I also found the below patches from openwrt patch site for 3.18 and 4.0
kernels which can be applicable to our kernel.=20

https://dev.openwrt.org/changeset/45653

But as described in the netdev mail-archive link above, it doesn=92t so=
lve
this issue completely and we still see the crash. I just wonder , if th=
e
proposed patch by =93Denys Fedoryshchenko=94, which is below, fixes thi=
s issue
completely.

=A0=A0=A0=A0=A0=A0=A0 pppox_unbind_sock(sk);
=A0=A0=A0=A0=A0=A0=A0 +/* Signal the death of the socket. */
=A0=A0=A0=A0=A0=A0=A0 +sk->sk_state =3D PPPOX_DEAD;


Do you have a conclusion on this bug? Is it safe to get this patch alon=
g
with the other workqueue patches?

Regards,
Murat
