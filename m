From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: more findings/questions on vlans/bonds
Date: Tue, 7 Apr 2009 12:14:46 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:17562 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753357AbZDGJO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 05:14:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay,

I hope that you can help clarify what's the correct/supported method
to work with vlans and bonds, with 2.6.29 I see that one can either

	- vlan a bond (bond0.4001 over bond0 over eth0/1.4001)
	- bond vlans (e.g bond0 over eth0/1.4001)

I played a bit with bonding vlans (2.6.29 active-backup mode) and it
doesn't seem to work - specifically, I noted that bonding doesn't issue
fail-over after I changed the current slave link status to down ("ifconfig
eth0.4001 down"). I suspect that the carrier based link monitoring scheme
is broken wrt to vlan devices - e.g I found that at least from sysfs
perspective the vlan device carrier isn't available:

$ cat /sys/class/net/eth0.4001/carrier
cat: /sys/class/net/eth0.4001/carrier: Invalid argument

I also played with a post 2.6.29 cut of Linus tree, and I couldn't bond vlans.
I thought that the reason may be that a vlan device has already master -
but I found out that its wrong and vlans don't have the IFF_SLAVE bit set
in their flags bit mask. So this may be either something wrong on my side
or a bug introduced after 2.6.29 or just something which isn't supported,
e.g following my findings with 2.6.29 above...

Or.
