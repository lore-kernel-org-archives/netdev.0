From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 24 Jul 2009 15:58:54 +0300
Message-ID: <200907241558.55235.remi.denis-courmont@nokia.com>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com> <200907221407.29275.remi.denis-courmont@nokia.com> <1248359692.774.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ext Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: ext Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1248359692.774.22.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 23 July 2009 17:34:52 ext Dan Williams wrote:
> There are any number of devices that expose only one AT port (which o=
f
> course gets used by PPP for data) and then a proprietary port.  The
> proprietary port usually uses a custom USB protocol that can also han=
dle
> SMS, status, RSSI, etc while the AT/PPP port is being used by ppp.
>
> So if that's the case for phonet, maybe you just want to provide eith=
er
> (a) documentation of the setup/status/sms/etc protocols, or (b) a shi=
m
> library implementation for them that handles communication with the
> device itself.

Eventually, Ofono should get the missing bits for GPRS-via-Phonet.

> But IMHO, the call setup stuff is probably better done from userspace=
=2E

I was referring to cellular data connectivity. Indeed, I wouldn't propo=
se=20
Netlink for network selection and circuit-switched services like SMS or=
 voice=20
calls :)

> It's a really hard API to abstract.  I guess you could write a netlin=
k
> API for it like we have for 802.11, but with GSM/CDMA the standards a=
re
> so widely ignored that it's just going to be impossible to get a stab=
le
> kernel API for anything like this.

Really, you only need a way to:
- create a device, e.g. like IPIP tunnel devices,
- set it up: access point name, and optionally username and password,
- bring it up, get IP and DNS configurations from the network,
- watch for context suspend events: IFF_NOCARRIER could do that,
- and eventually tear down.

In fact, it seems much simpler than 802.11. Well OK, I ignored "details=
" such=20
as secondary contexts and quality of service.

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
