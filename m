From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] 2.6.3 fix vlan-encapsulated fragmented IP traffic
Date: Mon, 1 Mar 2004 00:35:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040301003525.522d6db2.davem@redhat.com>
References: <200402291914.53578.bdschuym@pandora.be>
	<20040229215421.0ca987e8.davem@redhat.com>
	<200403010806.29759.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ebtables-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200403010806.29759.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Mar 2004 08:06:29 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> > I'm really concerned, btw, that this is going to propagate to other places
> > as well, what if something that gets handled this way gets sent over an
> > IPIP tunnel via some route, and then IPIP has to make all of these crazy
> > adjustments too?  That's going too far and we'll have to find a better
> > way if that is the case.
> 
> I'm not sure how IPIP tunnels are implemented, but I'm assuming they strip the 
> first IP header like the vlan code strips the vlan header when a vlan-packet 
> arrives on a vlan-enabled device. Then there should be no problem with this. 

Let us say that on input, br strips the 4 bytes as you say, iptables looks
at the thing and rewrites the IP source/destination address or whatever,
and this causes the packet to actually get forwarded out via a different IP
route, and let us say that this new IP route causes the packet to go out
via an IPIP tunnel device, which must do all the same kind of crap the code
you're patching here does, that is determine the LL header size etc. in order
to make sure there is enough headroom to slap on the new IP encapsulating
header.

If you can show that this kind of scenerio would never be generated in the
cases where br-netfilter is involved, then fine.
