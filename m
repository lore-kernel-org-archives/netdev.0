From: "Edgar E. Iglesias" <edgar.iglesias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 22:54:01 +0100
Message-ID: <20100126215401.GA25095@laped.iglesias.mooo.com>
References: <877hr5nkx0.fsf@purkki.valot.fi>
 <20100126.041610.226004766.davem@davemloft.net>
 <87wrz5m3cd.fsf@purkki.valot.fi>
 <20100126.050645.184040277.davem@davemloft.net>
 <87my01m0zm.fsf@purkki.valot.fi>
 <4B5EF5DF.2070005@lemonia.org>
 <87iqaplz5a.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dunc <dunc-9b9L1Hpe0sBAfugRpC6u6w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87iqaplz5a.fsf-ySPBbPOLdCfMApvqMRVM/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 04:27:29PM +0200, Kalle Valo wrote:
> Dunc <dunc-9b9L1Hpe0sBAfugRpC6u6w@public.gmane.org> writes:
> 
> > If applications set the QoS values, the who's to stop someone (for
> > example) writing a bittorrent client that marks all packets for the
> > highest priority as if they were VoIP or something?
> 
> Nobody. That would a bug in the application which should be fixed.
> Badly behaving applications can disrupt the network, with or without
> QoS support. So no need to blame QoS for this.

Fixing the app is not always an alternative, the damage may already
be done. You simply cannot always trust all the devices.

And, AFAIK you can setup "QoS" networks where a user's traffic won't
disturb others.


> And if the network doesn't want to trust applications, it's free to do
> so. Nothing prevents that. And based on the discussion so far, the
> networks already ignore QoS classifations coming from other network
> realms.

>From my experience, you have a mix of devices you trust and devices you
don't trust. For untrusted devices you want to classify and re-tag
their traffic as it enters your cloud, regardless of whatever the dev
tagged it with.

For trusted devices, typically stuff that is under the net admins control,
you let the device itself put the tags. This can be very useful for ex when
even advanced matching won't be able to differentiate between different
flows. For example, try to differentiate two ssl flows based on their
contents. Only the source can.

IMO what apps should be doing is setting the DSCP to a user configurable
value (config file or cmd line switch etc). This way people can choose DSCP
to whatever makes sense in their particular network. The default value
is of less interest.

WRT L3 vs L2, I think apps should normally be tagging by setting the DSCP
field. The kernel should provide configurable mappings between DSCP and
what ever L2 QoS that is available on the egress interface. As the packet
jumps and gets routed, the DSCP value gets remapped two every links
particular L2 "QoS" that matches the DSCP. After all, apps shouldn't need to
know their hooked up to a 802.11, wired ethernet or what ever is on the
route to the peer...

AFAIK, Linux already makes all of this perfectly possible.

My 2 cents..

Cheers
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
