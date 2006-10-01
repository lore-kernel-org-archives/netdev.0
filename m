From: Jeff Garzik <jeff@garzik.org>
Subject: ATM firestream bug
Date: Sun, 01 Oct 2006 10:45:40 -0400
Message-ID: <451FD494.1090804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:17804 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750706AbWJAOpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 10:45:43 -0400
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The gcc warning "may be used uninitialized" is correct here, as well:

drivers/atm/firestream.c: In function =91top_off_fp=92:
drivers/atm/firestream.c:1501: warning: cast to pointer from integer of=
=20
different size
drivers/atm/firestream.c: In function =91fs_open=92:
drivers/atm/firestream.c:870: warning: =91tmc0=92 may be used uninitial=
ized=20
in this function

This indicates two bugs:

1) not safe on 64-bit

2) variable 'tmc0' is indeed potentially used uninit'd, in particular i=
f=20
make_rate() returns an error (use occurs before error check).



