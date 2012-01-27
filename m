From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Fri, 27 Jan 2012 13:55:14 -0800
Message-ID: <CAEP_g=_NBunt-ZPdN2Uj+GKWn1GRE4Rwis20YRMXtKofJavysQ@mail.gmail.com>
References: <CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
 <20120125.203746.1977019610549185259.davem@davemloft.net> <CAGsizzLYxsc2MGxF7yK_QzS+3bexHa1F_6+NE87u3F18m7=R1g@mail.gmail.com>
 <20120126.133033.964571202129052712.davem@davemloft.net> <CAOzFzEj-UCXwhw0NA=Y=qExG=RdVJB3RAdqU0HrsMo7V+4eGcQ@mail.gmail.com>
 <1327643984.2919.6.camel@edumazet-laptop> <CAOzFzEjqy8G1khxxwKt=hJydz=gUAh8viahA0aVavtyBv7+MXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, steweg@ynet.sk,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joseph Glanville <joseph.glanville@orionvm.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOzFzEjqy8G1khxxwKt=hJydz=gUAh8viahA0aVavtyBv7+MXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2012 at 2:54 AM, Joseph Glanville
<joseph.glanville@orionvm.com.au> wrote:
> Under pathological load OVS suffers in benchmarks, continual
> establishment of new flows is really not good for it - I haven't
> observed this personally though.
> It does however worry me that this could be used as a viable DoS.. I
> don't really know what could be done to mitigate this however.

OVS allows each input port to have a separate genl socket associated
with it for the purpose of sending flow misses to userspace.
Currently userspace uses this to round-robin around these sockets when
handling flow setup requests in order to prevent one port from DoSing
the others.
