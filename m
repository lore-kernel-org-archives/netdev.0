From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCHv2 3/4] pci: Determine actual VPD size on first access
Date: Thu, 11 Aug 2016 09:54:56 +1000
Message-ID: <1470873296.3015.117.camel@kernel.crashing.org>
References: <1452684335-46107-1-git-send-email-hare@suse.de>
	 <1452684335-46107-4-git-send-email-hare@suse.de>
	 <20160209210458.GB32530@localhost>
	 <bc3c39b1-cbff-99a5-8fe7-9add14f2c6f5@ozlabs.ru>
	 <CAKgT0Udm0a08v34zU11ckjk4DCq2uxjPxmhLmgiKozY676Hruw@mail.gmail.com>
	 <1470787409.3015.81.camel@kernel.crashing.org>
	 <CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <helgaas@kernel.org>,
	Hannes Reinecke <hare@suse.de>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Babu Moger <babu.moger@oracle.com>,
	Paul Mackerras <paulus@samba.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	santosh@chelsio.com, Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UcfznUD2LM08focv7Y+vqLFMhqNiK5o1TUSsJFFYSt2Gg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-10 at 08:47 -0700, Alexander Duyck wrote:
> 
> The problem is if we don't do this it becomes possible for a guest to
> essentially cripple a device on the host by just accessing VPD
> regions that aren't actually viable on many devices. 

And ? We already can cripple the device in so many different ways
simpy because we have pretty much full BAR access to it...

>  We are much better off
> in terms of security and stability if we restrict access to what
> should be accessible. 

Bollox. I've heard that argument over and over again, it never stood
and still doesn't.

We have full BAR access for god sake. We can already destroy the device
in many cases (think: reflashing microcode, internal debug bus access
with a route to the config space, voltage/freq control ....).

We aren't protecting anything more here, we are just adding layers of
bloat, complication and bugs.

>  In this case what has happened is that the
> vendor threw in an extra out-of-spec block and just expected it to
> work.

Like vendors do all the time in all sort of places

I still completely fail to see the point in acting as a filtering
middle man.

> In order to work around it we just need to add a small function
> to drivers/pci/quirks.c that would update the VPD size reported so
> that it matches what the hardware is actually providing instead of
> what we can determine based on the VPD layout.
> 
> Really working around something like this is not much different than
> what we would have to do if the vendor had stuffed the data in some
> reserved section of their PCI configuration space.

It is, in both cases we shouldn't have VFIO or the host involved. We
should just let the guest config space accesses go through.

>   We end up needing
> to add special quirks any time a vendor goes out-of-spec for some
> one-off configuration interface that only they are ever going to use.

Cheers,
Ben.
