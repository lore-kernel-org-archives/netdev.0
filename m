From: Dan Williams <dcbw@redhat.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 11:02:30 -0700
Message-ID: <1255456950.2196.18.camel@localhost.localdomain>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009210909.GA9836@auslistsprd01.us.dell.com>
	 <20091009194401.036da080@nehalam>
	 <20091010044056.GA5350@mock.linuxdev.us.dell.com>
	 <20091010113219.3136fb8b@s6510>  <20091010210612.GA1927@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760461AbZJMSC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 14:02:57 -0400
In-Reply-To: <20091010210612.GA1927@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-10-10 at 14:06 -0700, Greg KH wrote:
> On Sat, Oct 10, 2009 at 11:32:19AM -0700, Stephen Hemminger wrote:
> > 
> > BTW, for our distro, we are looking into device renaming based on PCI slot
> > because that is what router OS's do. Customers expect if they replace the card
> > in slot 0, it will come back with the same name.  This is not what server
> > customers expect.
> 
> If your bios exposes the PCI slots to userspace (through the proper ACPI
> namespace), doing this type of naming should be trivial with some simple
> udev rules, no additional kernel infrastructure is needed.

By and large, the people that care most about persistent network device
names based on *location in the machine* are server users.  This allows
hotswap of cards or single-image-multiple-machine without needing
configuration changes, which is nice.

Those users can reasonably be expected to choose hardware whose BIOS
supports the ACPI tables that (mostly) guarantee to provide actual,
stable names for their hardware.  If there's even a 10% chance that on
consumer-level systems the names won't be stable on a given boot (and I
can't see how, without BIOS support, we can guarantee 100% stability)
then it's a worthless guarantee.

If the BIOS support exists, it is trivial to use udev to create the
correct naming mechanism for your machine, either using MAC address or
BIOS-provided slot naming.  No kernel patch is required.

If the BIOS support does not exist, you are not guaranteed a stable
naming mechanism except by MAC address, because the BIOS may randomly
change enumeration based on the time of day, or it may not.  A 90 or 95%
stability guarantee is not a guarantee at all.

Third, USB enumeration will always be unstable.  Thus we have an
unsolvable discrepancy in behavior between PCI and USB.

Is this correct?

Dan


