From: "Tim Wright" <timw@polyserve.com>
Subject: Arp undo issue in all 2.4 and 2.6 kernel releases
Date: Tue, 28 Nov 2006 11:37:22 -0800
Message-ID: <5D2570CAFC98974F9B6A759D1C74BAD00204911D@ex2.ms.polyserve.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Tim Wright" <timw@polyserve.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.pdx.polyserve.com ([216.64.170.69]:12774 "EHLO
	mail.pdx.polyserve.com") by vger.kernel.org with ESMTP
	id S936068AbWK1TiU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 14:38:20 -0500
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,
I have been tracking down a strange problem, and have a simple
"reproduce-by" and was looking for opinions from those better-versed in
the kernel networking code. Basically, it is possible to get a system
into a state where it responds to ARP requests even though no interface
has the address requested. Here is a simple reproduce-by:

Select an address in the same subnet as eth0
# ifconfig eth0:5 W.X.Y.Z netmask ... up
This works. Machine now responds to arp requests for W.X.Y.Z.
# ifconfig eth0:6 W.X.Y.Z netmask ... up
This fails as it should. But, the damage is done.
# ifconfig
You will only see eth0 and eth0:5. There is no eth0:6 interface. Good.
# ifconfig eth0:5 down
Now we are supposedly back to the original state. BUT the machine will
still respond to ARP requests for W.X.Y.Z

The easiest way to get out of this is to bring up eth0:5 again, and
bring it down again. However, this looks to me like the undo code when a
clashing address is found fails to clean up the arp side of things
correctly. Any clues here?

I am not on the netdev mailing list and will track responses on the
mailing list archives.

Thanks very much,

Tim Wright
