From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 20:53:27 +0200
Message-ID: <200412172053.28016.hasso@estpak.ee>
References: <41912F7A.6000408@redhat.com> <200412172003.22319.hasso@estpak.ee> <Pine.LNX.4.61.0412171206200.10943@gargoyle.wi.securepipe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Henrik Nordstrom <hno@marasystems.com>,
	Andrea G Forte <andreaf@cs.columbia.edu>,
	Harald Welte <laforge@gnumonks.org>,
	Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Martin A. Brown" <mabrown@securepipe.com>
In-Reply-To: <Pine.LNX.4.61.0412171206200.10943@gargoyle.wi.securepipe.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=DChel kenal p=E4eval (reede 17 detsember 2004 20:37) kirjutas Martin A=
=2E Brown:
> Hello Hasso and Andrea,
>
> We've gotten a little far afield from Neil Horman's initial question
> about why there are primary and secondary IPs, and I can't address yo=
ur
> concern Andrea about the (route cache?) 500ms latency between the tim=
e
> that an address is added (or removed) from an interface and the time =
that
> the address is actually used.  Even so, the Linux routing code allows=
 the
> kernel to suggest an IP with the "src" keyword.

I know.

>  : > Why change the primary address? What is wrong with simply changi=
ng
>  : > the route to use the other source IP?
>  :
>  : There is no support for it in most of user space software.
>  : None of the routing protocols suites support it etc.
>
> Though some software provides support for explicit configuration of
> source address for initiated sockets, you can use INADDR_ANY and let =
the
> kernel perform source address selection for you.

Well, that's the point - we want to have full control over this selecti=
on=20
process without doing fancy things in user space.=20

> Linux select an IP based on the routing table. [0]  Example:
>
>   # ip route show 192.168.90.0/24
>   192.168.90.0/24 dev eth0  scope link  src 192.168.90.250
>   # ip route change 192.168.88.0/24 dev eth0 scope link src $SECONDAR=
Y
>
> If you want to be fancy about it, you can have a higher preference
> routing table (make sure there's an entry in /etc/iproute2/rt_tables =
for
> $SECONDARY_TABLE).  Then you can add and remove tables in this routin=
g
> table instead of changing the route in the main routing table.
>
>   # ip rule add prio table $SECONDARY_TABLE
>   # ip route add table $SECONDARY_TABLE $DESTNET dev $REALDEV src
> $SECONDARY

All these tricks don't help if you are using dynamic routing.

--=20
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
