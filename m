From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Tue, 10 Feb 2004 01:06:15 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
 <20040209140853.69ab8bea.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209140853.69ab8bea.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 9 Feb 2004, David S. Miller wrote:

> I'm fine with this patch, although it appears incomplete because:

	Of course :) I'm still thinking on it, for example:

- do we need to complicate the things in arp_solicit and to
announce not only local IPs but also sender IPs for which we
support proxy_arp. But may be it is better not to complicate
the arp_solicit routine because it can detect different skbs
to same target, each with different saddr, so this is only a
matter of optimization.

	I'll send you final diff in the next days after resolving
this ifdef, I'm giving myself and the other gurus some days for
thinking :)

> > 2 - always use the best source address for this target
>
> The code handling this case is "#if 0/#endif" commented out in your
> patch.

	I just wanted to know if output route is better to use
in this case? Or it is better to use inet_select_addr?

> Finish this thing up, and as a birthday present to everyone I'll also
> add an IN_DEV_ARP_IGNORE flag for inet devices to so people can control
> complete ARP ignoring via a global/per-device sysctl.
>
> Hopefully, combined, this will get all the virtual server maniacs off
> of my back :-)

	Ah, no, forget about ARP_IGNORE :) Nobody wants this :)
As for IPVS like setups, the requirements need per IP tunning which
is possible only with some kind of filtering, not a global flag,
especially for the input device. Note that the "hidden" flag
is checked for the target device, this was the only way to
differentiate by device. May be this is a proof arp_announce is
not for IPVS :) It is mostly to work with other stacks because
I'm flooded with emails about how Linux ARP can be more friendly.

Regards

--
Julian Anastasov <ja@ssi.bg>
