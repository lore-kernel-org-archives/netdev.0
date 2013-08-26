From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: Can linux kernel bridge forward 802.1q tagged vlan
 packets?
Date: Mon, 26 Aug 2013 12:21:13 +0200
Message-ID: <20130826122113.805482d8.skraw@ithnet.com>
References: <20130822224453.ca93782f.skraw@ithnet.com>
	<20130822234941.4affc863@catus>
	<20130822151941.301cd36a@nehalam.linuxnetplumber.net>
	<20130823062234.c34a6da6.skraw@ithnet.com>
	<CAL3LdT62oN3hdrDy2DL_Mk9+vUAsRzxaSjY5O87HbHgsjG+V6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, Marek Kierdelewicz <marek@piasta.pl>,
	mitch.a.williams@intel.com, Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAL3LdT62oN3hdrDy2DL_Mk9+vUAsRzxaSjY5O87HbHgsjG+V6Q@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Aug 2013 21:58:58 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> Adding Carolyn Wyborny (igb maintainer) and Mitch Williams (igbvf maintainer)...
> 
> On Thu, Aug 22, 2013 at 9:22 PM, Stephan von Krawczynski
> <skraw@ithnet.com> wrote:
> > On Thu, 22 Aug 2013 15:19:41 -0700
> > Stephen Hemminger <stephen@networkplumber.org> wrote:
> >
> >> On Thu, 22 Aug 2013 23:49:41 +0200
> >> Marek Kierdelewicz <marek@piasta.pl> wrote:
> >>
> >> > Hi,
> >> >
> >> > >My general idea is to bridge tagged vlan packets from a physical
> >> > >interface (intel) to a virtual interface (virtio in qemu) and not
> >> > >losing the tags, so the qemu guest can use vconfig and friends to get
> >> > >some vlan interfaces. Is this possible and are there any additional
> >> > >steps necessary besides the usual bridge configuration?
> >> >
> >> > I'm using this setup with KVM virtualization (Qemu's successor). It
> >> > didn't work with default nic type for guest (realtek I think) as 802.1q
> >> > tags were not preserved properly in one of the directions. I don't
> >> > remember specifics. Anyway using e1000 driver instead of default fixed
> >> > it. Works like a charm.
> >>
> >> KVM e1000 Vnic doesn't do VLAN offloading at least in my experience.
> >> Virtio works fine.
> >
> > Ok guys, here is one of the major questions in this issue:
> >
> > How did you manage to convince the _host_ interface driver (in my setup "igb"
> > from intel) to get the vlan tagged packets from the LAN port. igb has a vlan
> > filter function built in and reads _no_ tagged packets at all if the driver
> > does not tell it to. And in case of "up-ing" the interface for attachment to a
> > bridge it does not configure this vlan filter.
> > How is this expected to work?
> >
> > --
> > Regards,
> > Stephan

Thanks Jeff,

so, since we are all here now :-) who can explain how one can tell either the
bridge or the attached network device to include certain VLAN IDs in its
HW filters so that these can be forwarded through the bridge?
>From the current infos it looks like a cheap network card with no HW filters
would just work (if I understood Stephen). But since most servers have either
intel cards or intel onboard chips (and they are brilliant in performance btw)
me and probably lots of others seem to need some solution that isn't currently
available. I would love to see something that really allows the card to still
use the filters and not switch it in complete promiscous mode so that every
packets floats in.
Any ideas?

-- 
Regards,
Stephan
