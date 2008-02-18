From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: "protocol 0300 is buggy" spam in dmesg when injecting&capturing on
	same interface
Date: Mon, 18 Feb 2008 17:39:03 +0200
Message-ID: <20080218153903.GA30253@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:56840 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbYBRQMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 11:12:48 -0500
Received: from tk-cn0002.oulu.fi (tk-cn0002 [130.231.63.2])
	by ee.oulu.fi (8.14.2/8.14.2) with ESMTP id m1IFd3wC009453
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2008 17:39:03 +0200 (EET)
Received: (from pp@localhost)
	by tk-cn0002.oulu.fi (8.14.2/8.14.2/Submit) id m1IFd3CC030714
	for netdev@vger.kernel.org; Mon, 18 Feb 2008 17:39:03 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When playing with some L2 level fuzzing I started getting lots of
"protocol 0300 is buggy, dev eth3" spew in dmesg. That interface is also
capturing the traffic that's being sent, that's probably why the
dev_queue_xmit_nit codepath is getting called in the first place.

Tested on 2.6.23-as-shipped-in-F8. didn't spot any relevant changes in .24
but can pretty easily verify there too. 

Oh. That printk wasn't very easy to find:

                              if (net_ratelimit())
                                        printk(KERN_CRIT "protocol %04x is "
                                               "buggy, dev %s\n",


and I naturally grepped for "is buggy". 

Any ideas? Add a "If it came from AF_PACKET, don't print out anything" to
that if-statement?


