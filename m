From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Thu, 02 Aug 2007 15:06:36 -0700 (PDT)
Message-ID: <20070802.150636.77057800.davem@davemloft.net>
References: <200708021115.10812.joachim.deguara@amd.com>
	<20070802.022317.66176729.davem@davemloft.net>
	<1186081829.18322.20.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joachim.deguara@amd.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753507AbXHBWGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 18:06:36 -0400
In-Reply-To: <1186081829.18322.20.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 02 Aug 2007 12:10:29 -0700

> On Thu, 2007-08-02 at 02:23 -0700, David Miller wrote:
> > From: "Joachim Deguara" <joachim.deguara@amd.com>
> > Date: Thu, 2 Aug 2007 11:15:05 +0200
> > 
> > > Seams like even if powersave shuts down the network that the device should 
> > > still work after a suspend to ram, so who is at fault here?
> > 
> > It's a good question.
> > 
> > The pci_enable() is done on the PCI device at probe time, at least in
> > the tg3 driver, and with such a model restoring and saving of PCI
> > config space should not be dependant upon whether the netdev is
> > running or not.
> > 
> 
> Alternatively, we can also fix it by calling pci_enable_device() again
> in tg3_open().  But I think it is better to just always save and restore
> in suspend/resume.  bnx2.c will also require the same fix.

We could do it that way.  But don't you think it's more reliable to
save and restore around the event we know will be what clobbers the
PCI config space on us? :-)

Other things might happen between ->resume() and ->open() that could
modify PCI config space, and we could overwrite such changes if we do
the PCI restore in ->open().

One thing that's interesting to me is that, essentially, every PCI
driver with very few if any exceptions needs to do this sequence on
suspend and resume.  It would be nice if there was a way to get this
to happen transparently by default, with some reasonable override
mechanism, for PCI device drivers.

Anyways, once your patch is tested feel free to send me the bnx2
one too.

Thanks!
