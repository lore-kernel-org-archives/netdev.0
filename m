From: Dan Williams <dcbw@redhat.com>
Subject: Re: Network link detection
Date: Mon, 07 Mar 2011 13:49:08 -0600
Message-ID: <1299527350.3269.11.camel@dcbw.foobar.com>
References: <20110303193006.GA29129@svh.nico22.de>
	 <4D700A5B.2000807@genband.com>
	 <20110303.140106.191399853.davem@davemloft.net>
	 <20110303222957.GA30472@svh.nico22.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, chris.friesen@genband.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Nico =?ISO-8859-1?Q?Sch=FCmann?= <dev@nico22.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110303222957.GA30472@svh.nico22.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-03 at 23:29 +0100, Nico Sch=C3=BCmann wrote:
> On Thu, Mar 03, 2011 at 02:01:06PM -0800, David Miller wrote:
> > From: Chris Friesen <chris.friesen@genband.com>
> > Date: Thu, 03 Mar 2011 15:38:35 -0600
> >=20
> > > You might look at whether you could write a kernel module to regi=
ster
> > > for NETDEV_CHANGE notifications and pass that back to userspace.
> >=20
> > This is the kind of responses you get when you ask networking speci=
fic
> > questions and don't CC: netdev :-/
> >=20
>=20
> Thank you for CC.
>=20
> > There is this thing called netlink, you can listen for arbitrary
> > network state change events on a socket, and get the link state
> > notifications you are looking for.  It's in use by many real
> > applications like NetworkManager and co.
>=20
> That really looks like what I'm looking for. I was already wondering=20
> where NetworkManager gets the link state changes from, but I just=20
> expected it to poll. So now I'll read a bit of documentation and=20
> hopefully get it work.

http://cgit.freedesktop.org/NetworkManager/NetworkManager/tree/src/nm-n=
etlink-monitor.c

NM uses libnl as the basic library for parsing netlink messages and
handling communication with the kernel.  Which is why you'll see a lot
of nl_* calls in there.  NM sets up the netlink connection using libnl,
then creates a GIOChannel to handle communication over the netlink
socket.  When something comes in (to event_handler()) the code handles
error conditions on the socket, then dispatches to libnl for processing=
=2E
libnl then calls back into NM to handle the actual message in
event_msg_ready().

Dan
