From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Tue, 17 Feb 2004 15:35:27 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402171529070.22129-100000@thoron.boston.redhat.com>
References: <20040217155452.GA9464@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040217155452.GA9464@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2004, Harald Welte wrote:

> On Sun, Feb 15, 2004 at 01:09:23AM -0500, James Morris wrote:

> > If the netfilter core code is modified instead, we will end up adding
> > skb_ip_make_writable() to nf_hook_slow() which will be called for every 
> > packet with an output device which uses hardware checksums.
> > 
> > Not sure which is worse, but here's a proposed patch which does this.
>  
> Why can't we somehow check inside the netfilter hook if the packet is
> at least multicast/broadcast (or even better: also locally generated)?

Well, we need to use skb_ip_make_writable() in any case (not just for
mcast/bcast packets), as we are modifying a part of the packet which 
may not be linear.  Note that this is only called for packets with an 
outdev, and does nothing if the transport layer checksum is writeable.


- James
--
James Morris
<jmorris@redhat.com>
