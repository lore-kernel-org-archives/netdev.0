From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Tue, 20 Jul 2010 15:29:54 +0100
Message-ID: <1279636194.2110.45.camel@achroite.uk.solarflarecom.com>
References: <4C457F72.8090708@redhat.com>
	 <1279624844.2110.3.camel@achroite.uk.solarflarecom.com>
	 <4C458CB7.3030508@redhat.com>
	 <1279627656.2110.13.camel@achroite.uk.solarflarecom.com>
	 <4C45996B.3000003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Andy Gospodarek <gospo@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Casey Leedom <leedom@chelsio.com>,
	Harald Hoyer <harald@redhat.com>
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C45996B.3000003@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-07-20 at 14:41 +0200, Stefan Assmann wrote:
> On 20.07.2010 14:07, Ben Hutchings wrote:
> > On Tue, 2010-07-20 at 13:47 +0200, Stefan Assmann wrote:
> >> On 20.07.2010 13:20, Ben Hutchings wrote:
> >>> On Tue, 2010-07-20 at 12:50 +0200, Stefan Assmann wrote:
> >>>> From: Stefan Assmann <sassmann@redhat.com>
> 
> [snip]
> 
> >> Actually Dave Miller suggested to put it there. What other place is
> >> there to put it?
> > 
> > If Dave said that then I'm sure it's OK.
> > 
> > However, if you define this as an interface flag (net_device::flags;
> > <linux/if.h>) and add it to the set of changeable flags in
> > __dev_change_flags(), user-space will be able to clear the flag if it
> > later sets a stable address.
> 
> As I said I'm not that knowledgeable about this MAC address stealing
> thing and I'm assuming that's what you're aiming at. Would you really
> want/need it to be user-space writable? Currently all I can think of is
> the scenario where you set a "stable" address that outlasts a reboot so
> udev might be able to assign it a permanent name after it gets stable.
>
> So it might make sense to have it writable, but I'd like to avoid to add
> unnecessary complexity that may cause errors if it's not necessary.
> Read-only is simple, just read the flag and deal with it.

Once this flag has been added, it may be used by any tool and not just
udev, so it ought to indicate the status of the currently assigned
address.  That requires that it be writable.

> Btw, the driver itself could also alter the flag. Then we'd have a well
> defined way of setting a stable address.

The driver can't know whether an address assigned by the user is stable.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
