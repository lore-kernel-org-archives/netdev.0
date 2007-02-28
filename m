From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: need some help on a backport of r8169
Date: Thu, 1 Mar 2007 00:08:07 +0100
Message-ID: <20070228230807.GB23772@electric-eye.fr.zoreil.com>
References: <20070226170941.GA17587@venus.synerway.com> <20070226234831.GA12830@electric-eye.fr.zoreil.com> <20070227110243.GA15657@venus.synerway.com> <20070227212400.GA12760@electric-eye.fr.zoreil.com> <20070228160133.GA8014@venus.synerway.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pgs@synerway.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52826 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbXB1XLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 18:11:01 -0500
Content-Disposition: inline
In-Reply-To: <20070228160133.GA8014@venus.synerway.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pgs@synerway.com <pgs@synerway.com> :
[...]
> The result is as follows :
> I boot my new kernel : the r8169 driver is automatically loaded and
> find the network card and gives me an eth0.
> I do a ifconfig, eth0 is up, with an IP and RX and TX are not 0.

Interesting.

> The problem comes here, I do a ping and it seems to have just the time
> to make the DNS resolution but not further. When I do a new ifconfig,
> the TX dropped is not 0 anymore. Then I can turn up and down my
> interface, I won't be able to ping anything.

Ok, almost perfect for a first try. :o)

If you can issue 'ifconfig' and do an ethtool dump of the registers at
the interesting points in time, it could surely help.

[...]
> Ah... poor me who thought that the RTL8168 was just like the RTL8169 with
> a pci express interface... It seems that a PCI-Express RTL8169 also
> exist right?

Remind me to check it later.

[...]
> Do you think my problem is the one you mentionned above, without the
> experimental patches?

It is possible. I should review the diffs too.

Once you have logged the ifconfig/ethtool dump, you can try the serie
or the patch at:

http://www.fr.zoreil.com/people/francois/backport/r8169/20070228-00

Btw:

[...dmesg dump...]
> Enabling fast FPU save and restore... done.
> Enabling unmasked SIMD FPU exception support... done.
> Checking 'hlt' instruction... OK.
> ACPI: setting ELCR to 0200 (from 0c08)
> NET: Registered protocol family 16
> PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=2
> PCI: Using MMCONFIG

Please disable MMCONFIG.

If you have any PCI latency option in your bios, set it to 64.

-- 
Ueimor
