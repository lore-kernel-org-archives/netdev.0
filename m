From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [2.6.31-rc1] iwlagn (4965): regression when hardware rf switch
 is used
Date: Mon, 29 Jun 2009 11:33:42 +0200
Message-ID: <1246268022.7775.24.camel@johannes.local>
References: <200906291128.05639.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-0wF0QopLZCySK2soLrq2"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200906291128.05639.elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-0wF0QopLZCySK2soLrq2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Now that I took a closer look...

> I've tried .31-rc1 on my HP 2510p notebook and noticed a problem when
> using the hardware rf kill switch.


> But with 2.6.31 I get this:
> [disable]
> wlan0: deauthenticating by local choice (reason=3D3)
> iwlagn 0000:10:00.0: Error sending REPLY_ADD_STA: enqueue_hcmd failed: -5
> mac80211-phy0: failed to remove key (0, 00:14:c1:38:e5:15) from hardware =
(-5)
> iwlagn 0000:10:00.0: Error sending REPLY_ADD_STA: enqueue_hcmd failed: -5
> mac80211-phy0: failed to remove key (1, ff:ff:ff:ff:ff:ff) from hardware =
(-5)
> usb 3-1: USB disconnect, address 2

These errors are a driver problem.

> [enable]
> usb 3-1: new full speed USB device using uhci_hcd and address 3
> usb 3-1: configuration #1 chosen from 1 choice

That is completely unrelated. You plugged in a USB device too :)

> A lot uglier with those errors. And after that I have to run ifdown/ifup
> before networking is up again (ifup only does not work as it will complai=
n
> "interface already configured"):

And that's actually expected, and/or a bug in the debian networking
scripts.
(You can trigger the same problem by doing
ifup wlan0
ip link set wlan0 down
ifup wlan0 -> error)

To get your network connection back automatically we will require
changes to userland tools to listen to rfkill events.

> BTW, would it make sense to bring back the first two lines shown with .30
> (or at least the first one):
>    iwlagn 0000:10:00.0: Radio Frequency Kill Switch is On:
>    Kill switch must be turned off for wireless networking to work.
> IMHO it's good to register the reason for the disconnect.

I guess something like that could be added to cfg80211:
phy0: taking interfaces down due to rfkill

johannes

--=-0wF0QopLZCySK2soLrq2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKSIpxAAoJEODzc/N7+QmaYdAQAJUA54sKACgxWVUQKJeJLBJP
4JDCQECM05HlbGvhAUQwTp4SBMIjqxTcMEt0d643V2DTolGBFFMy0PjUrYbEMizc
MVZTb3AHNThWIw0vQSKSn20hC5GQTl0Ahq4bkpMD13tfsto4VNL5BSmXg6mZxIN0
u/EPHhAz7LBxlBbx835imYUNSdXG1LcvObyGIyg+SLV0rRUMPduyH3MUUmlATFI0
tSVIsM9uEaTkXYjqdiuYxk8xWLU1pIiUyKGMSo4KJYqCs6YF8d1zqiFSejcwZmbw
Y+5CDDGznNIBqZBM5vrx6TW8LtoEJeg0eYzJpMRnqPexgPIaJlBJRFVmbxNgq0JW
Iu6rnLyGS3bpqnCnKUe8PiN3HZcnPJyTqb3Tg0Mx0sX6CxS/b9dRYoGYCRGNT2zM
xHaMJieBRopdN44U6Pj8ZO72OkkSOU8ZKkeC1nQ4xyGommeDZ1XtioqSyblP1Te1
x69aeqffBMrC3EUA6nvjvr92QQnHfgizhJJnViZWxZ+JJGuwtSiGc2la3FQD8S/e
OAo2zS1Vf2hnz+3MMv1hbNm7ZWKpn+siuqc55H7f+HNUZNu/sTuZhDfsR4uRerVQ
HjdF6gmXOdLbHasMuiUQ08hgG3bzEE3HqJVjwTBS8mIZfaHLQIBj9CkCsNymzGXc
fOzBKqqDJE7gHak2Xq81
=NrcQ
-----END PGP SIGNATURE-----

--=-0wF0QopLZCySK2soLrq2--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
