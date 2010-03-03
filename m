From: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>
Subject: increase in size for struct request_sock tolerable ?
Date: Wed, 03 Mar 2010 10:35:37 +0100
Message-ID: <4B8E2D69.5070900@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alan.p.smith@bt.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:43600 "EHLO
	smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311Ab0CCJqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 04:46:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

As part of the development of the MPTCP protocol=20
(http://inl.info.ucl.ac.be/mptcp), we are wondering whether it is=20
tolerable to extend the length of the struct request_sock. In the=20
current version of the protocol=20
(http://tools.ietf.org/id/draft-ford-mptcp-multiaddressed-02.txt), a=20
32bit token is exchanged as TCP options in the SYN and SYN/ACK segments=
=2E=20
AFAIU, that requires that we store 8 bytes in the request sock for the=20
server side, so that it remembers the local and remote tokens until the=
=20
real sock is created.Even worse, since the NULL token is not a reserved=
=20
value, we need to store an additional bit (flag) to know that we=20
received that TCP option. Since there are no flags currently stored in=20
the request_sock, we need to directly increase the size by 8 additional=
=20
bits.

So with the current protocol design, I arrive to a struct request_sock=20
extension of 4 (local token)+4(remote token)+1(1bit flag+7free flags)=3D=
9=20
bytes.

A minor protocol modification would allow reducing that constraint.=20
Basically, we would then differ the token exchange until the real sock=20
is created.    The flag would still be needed, though, thus in that cas=
e=20
we would arrive to 1 byte of extension only for the struct request_sock=
=2E

So my question is : Do you think there is a sufficient incentive here t=
o=20
adapt our protocol draft ? Or is it tolerable to extend the struct=20
request_sock by 9 bytes ?

Thanks in advance !

S=E9bastien.

--=20
S=E9bastien Barr=E9
Researcher,
CSE department, UCLouvain, Belgium
http://inl.info.ucl.ac.be/sbarre

