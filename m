From: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
Subject: Attempt to auto-load em_cmp.ko results in negative module refcnt
Date: Mon, 16 Feb 2015 11:59:12 +0100
Message-ID: <20150216105912.GA16798@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:57483 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755178AbbBPLAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2015 06:00:00 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YNJOr-0001Zp-48
	for netdev@vger.kernel.org; Mon, 16 Feb 2015 11:59:37 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YNJOS-0004h1-Fz
	for netdev@vger.kernel.org; Mon, 16 Feb 2015 11:59:12 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This simple test case

  tc qdisc add dev eth0 root handle 1: htb
  tc class add dev eth0 root classid 1: htb rate 1Gbit
  tc class add dev eth0 parent 1: classid 1:1 htb rate 1Gbit
  tc filter add dev eth0 parent 1: basic match 'cmp(u8 at 0 eq 0)' clas=
sid 1:1

fails with the following

  RTNETLINK answers: No such file or directory
  We have an error talking to the kernel

if em_cmp.ko is not loaded beforehand.

After that, lsmod shows that em_cmp.ko is loaded indeed, but its usage =
count
is -1 and an attempd to unload the module results in a "BUG at
kernel/module.c:752".

This has been broken pretty recently, I'm currently attempting a git bi=
sect on
this.

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
