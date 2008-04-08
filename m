From: Rick Jones <rick.jones2@hp.com>
Subject: showing which hardware is unclaimed
Date: Tue, 08 Apr 2008 13:13:01 -0700
Message-ID: <47FBD1CD.6090009@hp.com>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>	<36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com>	<20080408195949.GB28148@elte.hu> <20080408200417.GI11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:17286 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758070AbYDHUNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 16:13:06 -0400
In-Reply-To: <20080408200417.GI11962@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthew Wilcox wrote:
> On Tue, Apr 08, 2008 at 09:59:49PM +0200, Ingo Molnar wrote:
> 
>>Btw., a sidenote: this is another generally annoying property of Linux: 
>>there's no easy and user-visible enumeration of PCI IDs (devices) that 
>>we _could_ support but dont enable for some reason. It is a royal PITA 
>>to track down when some driver decides to (silently) ignore a piece of 
>>hardware.
>>
>>Having a seemingly dead piece of hardware component is one of the most 
>>frustrating user experiences possible - the first instinctive reaction 
>>is "did my hw break???". The kernel should proactively know about all 
>>inactive pieces of hardware and should have a one-stop-shop for users 
>>where they can reassure themselves which devices are not active and why.
> 
> 
> It's almost trivial to add new string attributes to sysfs.  We could
> have a file, say, /sys/bus/pci/devices/0000:07:03.0/broken which
> lspci could read to see if anything's left a message for us.
> 
> Is that the kind of thing you had in mind?

FWIW, this is what a command on "another OS" does with an unclaimed card:

# ioscan -fk -C lan
Class     I  H/W Path  Driver  S/W State   H/W Type     Description
====================================================================
lan       0  0/0/3/0   intl100   CLAIMED     INTERFACE    Intel PCI Pro 
10/100Tx Server Adapter
lan       1  0/1/2/0   igelan    CLAIMED     INTERFACE    HP PCI 
1000Base-T Core
lan       2  0/2/1/0   iether    CLAIMED     INTERFACE    HP A7012-60001 
PCI/PCI-X 1000Base-T Dual-port Adapter
lan       3  0/2/1/1   iether    CLAIMED     INTERFACE    HP A7012-60001 
PCI/PCI-X 1000Base-T Dual-port Adapter
lan       4  0/3/1/0   ixgbe     UNCLAIMED   UNKNOWN      PCI-X Ethernet 
(17d55831)

I'd probably call that "unclaimed" rather than "broken" but that may 
just be a preference thing.

rick jones

