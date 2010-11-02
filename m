From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] macvlan: Introduce a PASSTHRU mode to takeover the
 underlying device
Date: Tue, 2 Nov 2010 20:42:57 +0200
Message-ID: <20101102184257.GB2341@redhat.com>
References: <1288131578.7582.49.camel@sridhar.beaverton.ibm.com>
 <20101101082826.GA25879@redhat.com>
 <4CD05621.6000706@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, Arnd Bergmann <arnd@arndb.de>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CD05621.6000706@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 02, 2010 at 11:19:13AM -0700, Sridhar Samudrala wrote:
> On Mon, 2010-11-01 at 10:28 +0200, Michael S. Tsirkin wrote:
> 
>     On Tue, Oct 26, 2010 at 03:19:38PM -0700, Sridhar Samudrala wrote:
>     > With the current default macvtap mode, a KVM guest using virtio with
>     > macvtap backend has the following limitations.
>     > - cannot change/add a mac address on the guest virtio-net
>     > - cannot create a vlan device on the guest virtio-net
>     > - cannot enable promiscuous mode on guest virtio-net
>     >
>     > This patch introduces a new mode called 'passthru' when creating a
>     > macvlan device which allows takeover of the underlying device and
>     > passing it to a guest using virtio with macvtap backend.
>     >
>     > Only one macvlan device is allowed in passthru mode and it inherits
>     > the mac address from the underlying device and sets it in promiscuous
>     > mode to receive and forward all the packets.
>     >
>     > Thanks
>     > Sridhar
> 
>     One concern with promisc mode is that for the common case,
>     which is a single mac and no vlans, we will be getting
>     extra packets that will get dropped in userspace/guest
>     as compared to the case where same mac is programmed
>     in hardware and by guest.
> 
> In the tap/bridge model also, the external i/f is put in promiscuous mode and
> the
> bridge does the filtering of extra packets.

Yes but
1. that is much cheaper than passing them all the way up to the guest.
2. it's pretty painful for management to have to decide between
   features and speed. Better give them both :)

>     We could let userspace supply a list of mac/vlan addresses through
>     an ioctl on macvtap, and then
>     1. for a single mac, program it in hardware
>     2. for other configurations, set promisc mode
> 
>     tun already has TUNSETTXFILTER which might come in handy here.
>     We don't pass in vlans with the filter now but maybe we should.
>     How does this sound?
> 
> I guess this can be done. But i am not sure if we can extend the existing
> TUNSETTXFILTER
> to support vlans too. we may need a new ioctl.
> 
> Thanks
> Sridhar

OK. Maybe add it to tap too.

-- 
MST
