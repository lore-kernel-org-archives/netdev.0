From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH] net: Keep interface binding when sending packets with
	ipi_ifindex = 0
Date: Wed, 29 Jul 2009 19:10:21 -0500
Message-ID: <1248912621.13447.12.camel@merlyn>
References: <6c039e090907231439t1def08a4n10978733bee55bec@mail.gmail.com>
	 <20090727144402.513369f1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chia-chi Yeh <chiachi@android.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755781AbZG3AKg@vger.kernel.org>
In-Reply-To: <20090727144402.513369f1.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-07-27 at 14:44 -0700, Andrew Morton wrote:
> (cc netdev)
> 
> On Thu, 23 Jul 2009 14:39:28 -0700
> Chia-chi Yeh (_________) <chiachi@android.com> wrote:
> 
> > In IPv4, sending a packet with ipi_ifindex = 0 via an interface-bound
> > socket will unbind the packet to that interface. This behavior is
> > different from IPv6 which treats ipi6_ifindex = 0 as unspecified.
> > Furthermore, IPv6 does not allow sending packets to other interface
> > than the bound one, but I am not sure if it is necessary in IPv4. The
> > following patch keeps the interface binding when ipi_ifindex = 0.
> > 
> > Thanks,
> > Chia-chi
> > 
> > --- a/net/ipv4/ip_sockglue.c	2009-07-24 04:50:45.000000000 +0800
> > +++ b/net/ipv4/ip_sockglue.c	2009-07-24 04:51:09.000000000 +0800
> > @@ -213,7 +213,8 @@
> >  			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct in_pktinfo)))
> >  				return -EINVAL;
> >  			info = (struct in_pktinfo *)CMSG_DATA(cmsg);
> > -			ipc->oif = info->ipi_ifindex;
> > +			if (info->ipi_ifindex)
> > +				ipc->oif = info->ipi_ifindex;
> >  			ipc->addr = info->ipi_spec_dst.s_addr;
> >  			break;
> >  		}

A convenient copy of the man page says "When ipi_ifindex is not zero the
primary local address of the interface specified by the index overwrites
ipi_spec_dst for the routing table lookup."

But this is changing API behavior that's been this way since at least
the beginning of git history.

I guess Dave's letting this stand.  I'm posting this just to make sure
this is an explicit decision.

--
John
