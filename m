From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] 2.6.3 fix vlan-encapsulated fragmented IP traffic
Date: Sun, 29 Feb 2004 21:54:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229215421.0ca987e8.davem@redhat.com>
References: <200402291914.53578.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ebtables-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200402291914.53578.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 29 Feb 2004 19:14:53 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> When vlan-tagged fragmented IP traffic passes the bridging firewall and
> ip_conntrack is loaded and iptables sees this IP traffic, an oops can
> occur when trying to fragment the defragmented packets. This only
> happens in the slow_path of ip_fragment().
 ...
> The patch below fixes it. I saw no other way than to add some code to
> ip_fragment(), but this extra code is located in the slow_path so it's
> hardly ever executed.

Can you explain the 'mtu' fiddling a little bit?  I think it's correct...
but you know :)

The one case I'm concerned about is when the device does hw acceleration
of vlan tagging (ie. therefore things are transparent supposedly), is
the 'mtu' adjustment thing correct in that case?

I'm applying this for now, as I can't come up with a better fix either.
If we find a problem with this change, we'll fix that up.

I'm really concerned, btw, that this is going to propagate to other places
as well, what if something that gets handled this way gets sent over an
IPIP tunnel via some route, and then IPIP has to make all of these crazy
adjustments too?  That's going too far and we'll have to find a better
way if that is the case.
