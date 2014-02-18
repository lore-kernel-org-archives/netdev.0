From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [RFC v2 3/4] xen-netback: use a random MAC address
Date: Tue, 18 Feb 2014 11:22:55 +0000
Message-ID: <1392722575.11080.28.camel@kazak.uk.xensource.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	 <1392433180-16052-4-git-send-email-mcgrof@do-not-panic.com>
	 <5301E496.40802@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	<netdev@vger.kernel.org>, Wei Liu <wei.liu2@citrix.com>,
	<kvm@vger.kernel.org>, "Luis R. Rodriguez" <mcgrof@suse.com>,
	<linux-kernel@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	<xen-devel@lists.xenproject.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5301E496.40802@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-02-17 at 10:29 +0000, David Vrabel wrote:
> On 15/02/14 02:59, Luis R. Rodriguez wrote:
> > From: "Luis R. Rodriguez" <mcgrof@suse.com>
> > 
> > The purpose of using a static MAC address of FE:FF:FF:FF:FF:FF
> > was to prevent our backend interfaces from being used by the
> > bridge and nominating our interface as a root bridge. This was
> > possible given that the bridge code will use the lowest MAC
> > address for a port once a new interface gets added to the bridge.
> > The bridge code has a generic feature now to allow interfaces
> > to opt out from root bridge nominations, use that instead.
> [...]
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -42,6 +42,8 @@
> >  #define XENVIF_QUEUE_LENGTH 32
> >  #define XENVIF_NAPI_WEIGHT  64
> >  
> > +static const u8 xen_oui[3] = { 0x00, 0x16, 0x3e };
> 
> You shouldn't use a vendor prefix with a random MAC address.  You should
> set the locally administered bit and clear the multicast/unicast bit and
> randomize the remaining 46 bits.

I'd have thought that eth_hw_addr_random would get this right, *checks*
yes it does. And then this patch tramples overt the top three bytes.

Might there be any requirement to have a specific MAC on the vif device?
IOW do we need to figure out a way to plumb this through the Xen tools
(perhaps having the vif script sort it out).

Speaking of which -- do the Xen tools not overwrite this random mac from
xen-network-common.sh:_setup_bridge_port. What is the plan to change
that (in a forwards/backwards compatible manner).

Ian.
