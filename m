From: "Matthew G. Marsh" <mgm@paktronix.com>
Subject: Re: Resend:  SIOCGIFBRDADDR?
Date: Sun, 18 Aug 2002 09:21:12 -0500 (CDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.43.0208180910010.27516-100000@netmonster.pakint.net>
References: <Pine.LNX.4.44.0208151441350.9904-100000@kaneda.isrd.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Kevin Dwyer <kevin@pheared.net>
In-Reply-To: <Pine.LNX.4.44.0208151441350.9904-100000@kaneda.isrd.lan>
List-Id: netdev.vger.kernel.org

On Thu, 15 Aug 2002, Kevin Dwyer wrote:

> On Thu, 15 Aug 2002, kuznet@ms2.inr.ac.ru grunted something like:
>
> Thanks for the response...
>
> > > crazy.  So my question: Does anyone know if there's an ip route command to
> > > make the Bcast field show up as the correct value,
> >
> > Yes, that one which is described in manual (and equivalent to corresponding
> > ifconfig)
> >
> > ifconfig eth0:tra-ta-ta 10.x.y.z etc.
>
> Perhaps I should clarify a bit further.
> When we are starting heartbeat, the interface is setup thusly:
> (I've simplified this to make it easier to read)
>
> ifconfig eth0 10.5.5.8 broadcast 10.5.5.255 netmask 255.255.255.0
> ip -f inet addr add 10.5.5.1 dev eth0 scope link
> ip -f inet addr add 10.5.5.2 dev eth0 scope link

Why do you use the 'scope link' statements?

And as far as your original question try the following:

ip -f inet addr add 10.5.5.8/24 dev eth0 brd +
ip -f inet addr add 10.5.5.1 dev eth0 scope link brd 10.5.5.255
ip -f inet addr add 10.5.5.2 dev eth0 scope link brd 10.5.5.255

And then you will have the output of 'ip ad li dev eth0' as:

3: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:c0:9f:0c:5f:db brd ff:ff:ff:ff:ff:ff
    inet 10.5.5.1/32 brd 10.5.5.255 scope link eth0
    inet 10.5.5.2/32 brd 10.5.5.255 scope link eth0
    inet 10.5.5.8/24 brd 10.5.5.255 scope global eth0

And also you will then have 'ifconfig eth0':

eth0      Link encap:Ethernet  HWaddr 00:C0:9F:0C:5F:DB
          inet addr:10.5.5.2  Bcast:10.5.5.255  Mask:255.255.255.255
          UP BROADCAST MULTICAST  MTU:1500  Metric:1

Work for you?

[snip]

> -[ kevin@pheared.net                 devel.pheared.net ]-
> -[ Rather be forgotten, than remembered for giving in. ]-
> -[ ZZ = g ^ (xb * xa) mod p      g = h^{(p-1)/q} mod p ]-

And if I am way off base here due to jumping in just ignore me.

--------------------------------------------------
Matthew G. Marsh,  President
Paktronix Systems LLC
1506 North 59th Street
Omaha  NE  68104
Phone: (402) 932-7250 x101
Email: mgm@paktronix.com
WWW:  http://www.paktronix.com
--------------------------------------------------
