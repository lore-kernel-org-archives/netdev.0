From: Michael Tokarev <mjt@tls.msk.ru>
Subject: iproute equivalent of replacing address with ifconfig?
Date: Mon, 18 May 2015 17:03:37 +0300
Message-ID: <5559F139.2010801@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:59577 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbbEROKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 10:10:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I'm trying to find a more or less easy way to set an address of
an "interface" (I understand an interface can have N addresses).
Traditionally it was done by a comand

 ifconfig $iface 1.2.3.4 mask 5.6.7.8

What it does is effectively _replaces_ currently set address
to a new one, or just sets a new address if it is already set.
And it does that more or less atomically, at least in one go,
so that if the network has been configured before it remains
working after the command if it is successful.

ip addr command however does not have the ability to "replace"
an address, there are two commands for that, del and add.
So in order to change address, one have to delete and add,
a two-step process.  Adding an address before deleting might
not work as the new address should not conflict with old
address in any way, or else addition fails.

What I'm thinking about is, for example, a system running
out of a remote nfs root, with a dhcp client running.
Initially address has been configure by the boot loader
and is provided to the kernel/initramfs in terms of ip=
boot option.  When the system is booted, it starts dhcpc
which has to (re)configure the interface.  With ifconfig
it works just fine, but with ip addr it doesn't, since once
the old address is deleted, nfs root simple stops working,
and there's no way anymore to run anything at all.

Trying to see which addresses are already configured for
the interface, what has changed compared to the new address
etc, and working around various combinations and conflicts
in shell is not really an option, it quickly becomes
unmanageable.

What's the closest equivalent of `ifconfig $iface $address'
command to set-or-replace a (named) IP address?

Thanks,

/mjt
