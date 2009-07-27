From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Mon, 27 Jul 2009 13:36:06 -0400
Message-ID: <1248716166.17189.25.camel@localhost.localdomain>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	 <200907241431.08858.oliver@neukum.org>
	 <20090724134805.0d9496be@lxorguk.ukuu.org.uk>
	 <200907241612.41871.oliver@neukum.org>  <1248458401.28545.149.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1248458401.28545.149.camel@violet>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-07-24 at 20:00 +0200, Marcel Holtmann wrote:
> Hi Oliver,
> 
> > > > No, I was thinking of having two full devices, a data channel and a
> > > > control channel for devices that really talk AT commands natively.
> > >
> > > If the hardware does it great, however for things like a 3G modem you
> > > have the problem that the PPP is over the AT command channel which may
> > > itself be multiplexed. And the muxing in question is *ugly* - sort of
> > > HDLC and LAP-B done wrong.
> > 
> > Well, yes, but we would really like a separate control channel, so we
> > can query parameters like signal strength, while we do PPP over the data
> > channel.
> 
> we don't want PPP at all. It is just plain stupid and a total braindead
> idea. Non of the GSM/UMTS networks talk PPP over the air interface or
> actually anywhere in their stack. The PPP is just between the host OS
> and the card. It is a pointless encapsulation of IP packets that comes
> from the POTS stuff where PPP over a telephone line made sense.

Feel free to convince all the hardware vendors to move over to that
model.  Many of them are, but there are still *boatloads* of devices
that do PPP.  It'll be at least 3 or 4 years before you can even think
about ignoring PPP entirely.

This is totally a firmware thing and not something under our control at
all.  Either the vendor implements a non-PPP data channel, or they
don't.  We have to live with that, or ignore devices that use PPP.  Most
of the devices out there use PPP.  Maybe 80 or 90%.

The only reason vendors ditched PPP was that it was too much overhead to
achieve full speed on HSDPA 7.2 networks.  Guess how many operators have
actually deployed HSDPA 7.2?  Count them on your hands.  Yes, over the
next year or two we'll see a lot more HSDPA 7.2-capable networks, and
that means more devices will show up that ditch PPP.  But at the moment,
PPP can't be ignored.

The next problem is that not all vendors implement the non-PPP data
channel using cdc-ether, or provide specs/drivers for that channel.  So
just because a vendor ditches PPP doesn't automatically mean it's better
for Linux and a driver is available.

Dan

> And on top of that we have these magic *99# phone numbers to establish a
> PDP context, because the OS still sees them as POTS modem. All stupid
> and braindead. I am so happy that Ericsson and Option moved to proper
> high speed network devices and that Nokia Phonet had this all along.
> 
> So besides the GPRS data access, the other problem with AT command
> control channels is that they are by no means async. Every single
> command is essentially blocking and so you need the TTY mux anyway so
> you can do scanning, text messaging and network monitoring at the same
> time without having your application look like a total dork.
> 
> Regards
> 
> Marcel
> 
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
