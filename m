From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: tcp_close - why no WARN_ON ?
Date: Mon, 19 Dec 2011 13:57:35 +0100
Message-ID: <4EEF34BF.7050302@uclouvain.be>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:32831 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568Ab1LSM5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 07:57:41 -0500
Received: from [130.104.228.43] (cpaasch-mac.dhcp.info.ucl.ac.be [130.104.228.43])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: cpaasch@smtp6.sgsi.ucl.ac.be)
	by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPSA id BC4291C52D5
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 13:57:35 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am trying to understand the following code in tcp_close:

  sock_orphan(sk);

  /* It is the last release_sock in its life. It will remove backlog. *=
/
  release_sock(sk);

  /* Now socket is owned by kernel and we acquire BH lock
     to finish close. No need to check for user refs.
   */
  local_bh_disable();
  bh_lock_sock(sk);
  WARN_ON(sock_owned_by_user(sk));


How is it possible that between release_sock(sk) and local_bh_disable()=
,
no other thread gets scheduled and calls lock_sock() and thus the
WARN_ON would be triggered ?


Can someone please point me to the lines of code that handle this ?


Thanks a lot,
Christoph



--=20
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
Universit=E9 Catholique de Louvain
--=20
