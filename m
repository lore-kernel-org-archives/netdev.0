From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Fri, 27 Jan 2012 13:50:49 -0800
Message-ID: <CAEP_g=-BwxSA6Wbs=HjJbTic3bZ5tBXCocvSvFkxXQGzKzNTnQ@mail.gmail.com>
References: <CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
 <20120125.203746.1977019610549185259.davem@davemloft.net> <CAGsizzLYxsc2MGxF7yK_QzS+3bexHa1F_6+NE87u3F18m7=R1g@mail.gmail.com>
 <20120126.133033.964571202129052712.davem@davemloft.net> <CAOzFzEj-UCXwhw0NA=Y=qExG=RdVJB3RAdqU0HrsMo7V+4eGcQ@mail.gmail.com>
 <1327643984.2919.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joseph Glanville <joseph.glanville@orionvm.com.au>,
	David Miller <davem@davemloft.net>, steweg@ynet.sk,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327643984.2919.6.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 26, 2012 at 9:59 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 27 janvier 2012 =C3=A0 09:24 +1100, Joseph Glanville a =C3=
=A9crit :
>> David is correct, the forwarding speed of Open vSwitch is at parity
>> with the Linux Bridging module and its tunneling speed is actually
>> slightly faster than the in kernel GRE implementation. I have tested
>> this across a variety of configurations.
>
> Thanks for this input ! When was this tested exactly, and do you have
> some "perf tool" reports to provide ?
>
> GRE is lockless since one year or so (modulo how is setup the tunnel =
as
> discovered recently)

The out-of-tree OVS GRE stack (which is separate for practical and
historical reasons but I would like to combine with the in-kernel one
in the future) uses a few dirty tricks to help performance.  I don't
know the parameters that Joseph used to test but one that he might be
benefiting from here is where we cache the full set of headers to be
pushed (GRE/IP/Ethernet) as well any routing/switching decisions.
This turns a GRE encapsulation into a simple memcpy if there is enough
headroom.  It's not something that I would want to propose for more
general usage but I think that GSO/GRO for GRE would get at least some
of that benefit and would also make things easier when NICs with
support for encapsulated offloads start showing up.
