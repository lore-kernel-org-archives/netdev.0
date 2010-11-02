From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [SECURITY] CAN info leak/minor heap overflow
Date: Tue, 02 Nov 2010 14:28:23 -0400
Message-ID: <1288722503.2504.14.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: socketcan@hartkopp.net, oliver.hartkopp@volkswagen.de,
	urs.thuermann@volkswagen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:57081 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785Ab0KBS21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 14:28:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bcm_connect() (in net/can/bcm.c), I noticed the following code:

	sprintf(bo->procname, "%p", sock);

"procname" is a 9-byte char array.  This code is wrong on two levels.
First, leaking a kernel address via a /proc filename is bad.  Secondly,
on 64-bit platforms, up to 17 bytes may be copied into the buffer.
Fortunately, structure padding will most likely prevent this from being
a problem, except for the trailing NULL byte, which may overwrite the
first byte of the next heap object.  Please name your procfile in a way
that doesn't leak information and fits into the desired name buffer.

-Dan

