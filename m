From: Peter Stuge <stuge-vlan@cdy.org>
Subject: Re: [VLAN] Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge device
Date: Fri, 5 Sep 2003 13:42:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905114214.GC17851@foo.birdnet.se>
References: <200308301504.03241.bdschuym@pandora.be> <3F50FF0E.9020004@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S.Miller" <davem@redhat.com>, netdev@oss.sgi.com, vlan@wanfear.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <3F50FF0E.9020004@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 30, 2003 at 12:46:22PM -0700, Ben Greear wrote:
> Bart De Schuymer wrote:
> >The patch below disables making vlan devices on top of bridge
> >devices, f.e. br0.12 would be impossible.
> >I'm no vlan expert, but I don't see the use for this and allowing it
> >will make the bridge-nf code hairy if we want to let {ip,arp}tables see
> >{IP,ARP} traffic that is embedded in a vlan header.

I think being able to make a br0.12 is a very good thing, but if it isn't
working properly all the way through *tables, I'd say it's better to take
the possibility away. When someone needs br0.12 bad enough she or he can
deal with the bridge-nf code as well.


> >Also, situations like eth0.15 being a bridge port of br0.16 seem
> >unwanted (to me).

Not neccessarily, since Linux can be connected to multiple "VLAN domains"
(is there a proper term for it?) - that is, all of the VLANs on one
interface could be completely separate from all VLANs on another interface,
making eth0.15 a bridge port of br0.16 only logical.

Admittedly large setups, though.


> However, I'm forwarding this to the vlan mailing list, as I know there
> are folks there who use vlans and bridging a lot....  For those who
> care, please speak up if you need this functionality for some reason...

If {i,ar}ptables doesn't deal with VLANs on bridge ports there's no point in
keeping it, IMHO.


//Peter
