From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Prism / Hostap Bridge Problems...
Date: Mon, 13 Dec 2004 10:48:08 -0800
Message-ID: <20041213104808.175afc52@dxpl.pdx.osdl.net>
References: <41B9B6E9.7010600@novolab.de>
	<41B9C4E0.40407@novolab.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Brande <brande@novolab.de>, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Brande <brande@novolab.de>
In-Reply-To: <41B9C4E0.40407@novolab.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Read the FAQ=20
http://bridge.sourceforge.net/faq.html
-------------
It doesn't work with my Wireless card!
This is a known problem, and it is not caused by the bridge code. Many wi=
reless cards don't allow spoofing of the source
address. It is a firmware restriction with some chipsets. You might find =
some information in the bridge mailing list
archives to help.

Has anyone found a way to get around Wavelan not allowing anything but it=
s own MAC address?
(answer by Michael Renzmann (mrenzmann at compulan.de))

Well, for 99% of computer users there will never be a way to get rid of t=
his. For this function a special firmware is
needed. This firmware can be loaded into the RAM of any WaveLAN card, so =
it could do its job with bridging. But there is
no documentation on the interface available to the public. The only way t=
o achieve this is to have a full version of the
hcf library which controls every function of the card and also allows acc=
essing the card=B4s RAM. To get this full version
Lucent wants to know that it will be a financial win for them, also you h=
ave to sign an NDA. So be sure that you won=B4t
most probably get access to this peace of software until Lucent does not =
change its mind in this (which I doubt never
will happen).

If you urgently need to have a wireless LAN card which is able to bridge,=
 you should use one of those having the prism
chipset onboard (manufactured by Harris Intersil). There are drivers for =
those cards available at www.linux-wlan.com
(which is the website from Absoval), and I found a mail that says that th=
ere is the necessary firmware and an upload
tool available for Linux to the public. If you need additional features o=
f an access point you should also talk to
Absoval.

I still don't understand!!
(answer by Mark S. Mathews (mark at absoval.com))

Bridging Ethernet (v2 or 802.3) is predicated on the ability of a station=
 to transmit frames with a source address (SA)
other than its own. This is possible because Ethernet uses a 'transmit an=
d forget'/stateless transmission model.

This isn't possible with 'normal' 802.11 station cards and software becau=
se 802.11 station mode doesn't allow the
transmission of frames with 'someone else's source address. The primary r=
eason is that 802.11 is an acknowledged
protocol. If you transmit a frame with someone else's source address, the=
 ACK will never come back to you. The ACK will
be sent to the station whose source address you used.

There are ways to make it work (that's how I earn a living ;-), but it is=
 not always straightforward and you probably
won't get it right without a pretty solid understanding of 802.11, it's m=
odes, and the frame header format.
