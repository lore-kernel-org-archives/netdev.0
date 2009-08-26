From: Chris Ross <chris@compilednetworks.com>
Subject: skb header allocation
Date: Tue, 25 Aug 2009 22:04:10 -0500
Message-ID: <17cd85320908252004r31874732n9e06921d6eae4ad7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:50133 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585AbZHZDEI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 23:04:08 -0400
Received: by pxi12 with SMTP id 12so3915824pxi.22
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 20:04:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a network driver that acts as a Ethernet device and builds up a
series of outer headers on skb(s) it receives from upper layers. I am
currently using the technique that is in ipip.c to ensure I have
enough room to add my header ...

if (skb_headroom(skb) < some_value || skb_shared(skb) ||
=A0=A0=A0=A0=A0=A0=A0=A0 ((skb_cloned(skb) && !skb_clone_writable(skb, =
0))))
=A0=A0 {
=A0=A0=A0=A0=A0 if ((skb2 =3D skb_realloc_headroom(skb, some_value)) =3D=
=3D NULL)
=A0=A0=A0=A0=A0=A0=A0=A0 return -1;

=A0=A0=A0=A0=A0 dev_kfree_skb(skb);
=A0=A0=A0=A0=A0 skb =3D skb2;
=A0=A0 }

Is this the best practice for a high bandwidth scenario?

thanks

-chris
