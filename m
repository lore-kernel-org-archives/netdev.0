From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Miscalculated TCP ACK ?
Date: Mon, 22 Aug 2011 18:38:48 +0200
Message-ID: <1314031128.2307.110.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Gabriel Beddingfield <gabrbedd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60852 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054Ab1HVQir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 12:38:47 -0400
Received: by wyg24 with SMTP id 24so3621048wyg.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 09:38:46 -0700 (PDT)
In-Reply-To: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 10:34 -0500, Gabriel Beddingfield a =C3=
=A9crit :
> I'm having trouble with a particular server via HTTPS.  It appears
> that my local linux machines are sending incorrect ACK.  However, I
> don't have enough expertise to know for sure.
>=20
> Using wireshark, the server sends:
>=20
>     Transmission Control Protocol, Src Port: https (443), Dst Port:
> 36015 (36015), Seq: 27658, Ack: 827, Len: 18
>=20
> Local machine replies:
>=20
>     Transmission Control Protocol, Src Port: 36015 (36015), Dst Port:
> https (443), Seq: 827, Ack: 27677, Len: 0
>=20
> It appears to me that the ACK is off-by-one (should have been 27676).
> The server replies again with retransmissions.  This is with several
> kernel versions on local machines, ranging from 2.6.31 to 2.6.38.
>=20
> Can anyone shed insight into what's happening?  This looks like a bug=
 to me.

Not a bug if frame carried a FIN

18:32:16.177801 IP 10.150.51.213.52264 > 10.150.45.194.22: Flags [F.], =
seq 3312, ack 3241, win 412, length 0
18:32:16.178096 IP 10.150.45.194.22 > 10.150.51.213.52264: Flags [F.], =
seq 3241, ack 3313, win 203, length 0
18:32:16.256949 IP 10.150.51.213.52264 > 10.150.45.194.22: Flags [.], a=
ck 3242, win 412, length 0


