From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: a couple questions about drivers/net/macv*.c
Date: Sat, 10 Jul 2010 19:44:59 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.1007101652030.7658@lynx>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:41621 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840Ab0GKCRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 22:17:30 -0400
Received: from dsl-173-206-152-127.tor.primus.ca ([173.206.152.127] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1OXjjE-0001u4-Ax
	for netdev@vger.kernel.org; Sat, 10 Jul 2010 19:45:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  first (trivial) point, i notice that both macvlan.c and macvtap.c
are still both listed as EXPERIMENTAL -- is that still accurate?

  bigger issue in macvtap.c -- notice this declaration:

static unsigned int macvtap_major;

that seems like a violation of coding style since that variable is
used later on in:

        devt = MKDEV(MAJOR(macvtap_major), dev->ifindex);
 and

       err = alloc_chrdev_region(&macvtap_major, 0,
                                MACVTAP_NUM_DEVS, "macvtap");

where its type should simply be the typedef "dev_t" for transparency,
should it not?  hardcoding that variable as an unsigned int seems like
a bad idea.

rday

-- 

========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

        Top-notch, inexpensive online Linux/OSS/kernel courses
                        http://crashcourse.ca

Twitter:                                       http://twitter.com/rpjday
LinkedIn:                               http://ca.linkedin.com/in/rpjday
========================================================================
