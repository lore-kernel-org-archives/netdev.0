From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH RFC 0/1] usb: Tell xhci when usb data might be misaligned
Date: Thu, 30 Jan 2014 15:59:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B5460@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43086 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753218AbaA3QAQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 11:00:16 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22461-04 for <netdev@vger.kernel.org>;
 Thu, 30 Jan 2014 16:00:11 +0000 (GMT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've marked this as RFC because I'm not sure whether this should
go through the usb tree or netdev.

I'm also not 100% sure that the code that generates a urb should
'know' the entire aligment rules of the host controller.
However this was already done when the flag was added to indicate
that 'unconstrained' fragmentation was supported by xhci.

This patch fixes problems with long scatter-gather lists on xhci bulk
endpoints by removing the limit on the number of entries and requesting
that the code that generates urb mark those that might have misaligned
fragments - which need special treatment.

The xhci driver cannot give a simple limit to the number of fragments
in a non-aligned transfer because it has to further split the fragments
on 64k address boundaries.

The only code (I can find) that currently generates non-aligned tranfers
is in usbnet.

It is important that all these patches be applied together.
More specifically the change xhci-ring.c must be applied AFTER the
change to usbnet.c.
Failure to do so will break some configurations including those using
the ax88179_178a usb ethernet on hosts with the Intel Panther Point
chipset (which I think is the newest one).

David Laight (1):
  usb: Tell xhci when usb data might be misaligned

 drivers/net/usb/usbnet.c     |  1 +
 drivers/usb/host/xhci-ring.c | 12 ++++++++----
 drivers/usb/host/xhci.c      |  8 ++++++--
 include/linux/usb.h          |  1 +
 4 files changed, 16 insertions(+), 6 deletions(-)

-- 
1.8.1.2
