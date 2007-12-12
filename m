From: Yogesh Raju Sreenivasan <sreeniva@cse.psu.edu>
Subject: Labeled IPsec with NAT
Date: Tue, 11 Dec 2007 22:37:06 -0500
Message-ID: <54AF31FD-9D60-44A6-B7B8-C71893ADCCED@cse.psu.edu>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-7-80094948"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from psuvax1.cse.psu.edu ([130.203.4.6]:64345 "EHLO mail.cse.psu.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083AbXLLEQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 23:16:29 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.cse.psu.edu (CSE Mail Server) with ESMTP id 53E751238C
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 22:37:13 -0500 (EST)
Received: from mail.cse.psu.edu ([127.0.0.1])
 by localhost (psuvax1 [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 28335-03-61 for <netdev@vger.kernel.org>;
 Tue, 11 Dec 2007 22:37:11 -0500 (EST)
Received: from [172.28.37.195] (client-128-118-186-52.mobility-up.psu.edu [128.118.186.52])
	by mail.cse.psu.edu (CSE Mail Server) with ESMTP id 1735612363
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 22:37:10 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-7-80094948
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed


I am working on setting up Labeled IPsec along with iptables nat  
rules. Once I insert nat related rules, the ipsec connection breaks  
and the system tries to re-negotiate and creates multiple SAs. I am  
using 2.6.19 kernel (with Venkat's MLSXFRM patches & bugfixes). I  
guess those were incorporated into the 2.6.20 kernel.

In my case, the function ip_route_me_harder() calls the xfrm_lookup()  
second time which is causing the re-negotiation. I believe it is  
because the flowi->secid field is not set during the second  
xfrm_lookup() call. The ip_route_me_harder() function also calls the  
xfrm_decode_session() which I guess creates/fills the flowi details  
and selinux_xfrm_decode_session fills the flowi->secid from the  
skbuff->sec_path field. But since the skbuff->secpath field is not  
set, the flowi->secid field is reset to 0 on the decode_session()  
call. It seems like we have to fill in the secpath while creating the  
skbuff, before calling the xfrm_decode_session, for the output flow.

Please do let me know if someone has already looked into this issue  
and would be helpful if you could guide me with this. If someone has  
already tested labeled ipsec with NAT and if my understanding is not  
correct do let me know, I am new to linux kernel and finding it  
difficult to reason out the exact cause.

Thanks
Yogesh

--Apple-Mail-7-80094948
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (Darwin)

iD8DBQFHX1ditwxrN9RHNvQRAtKWAJ98arBdf6xj0mTQoFutuVZBpRAU9QCfarPX
wklHmt3y8GSYuQKs3v3vBvc=
=AZvd
-----END PGP SIGNATURE-----

--Apple-Mail-7-80094948--
