From: Erik Hensema <erik@hensema.net>
Subject: Re: RFC: promote netfilter MARK value from IPv6 packets to sit packets
Date: Mon, 24 Feb 2003 00:42:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030223234225.GA23556@hensema.net>
References: <20030217145727.GA3413@hensema.net> <20030223193339.GD15385@sunbeam.de.gnumonks.org>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>, netdev@oss.sgi.com,
   Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
In-Reply-To: <20030223193339.GD15385@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 23, 2003 at 08:33:39PM +0100, Harald Welte wrote:
> On Mon, Feb 17, 2003 at 03:57:27PM +0100, Erik Hensema wrote:
> 
> > In order to be able to provide QoS on tunneled IPv6 connections, I've
> > created a simple patch (definately not ready for inclusion in the kernel,
> > since it surely needs a configuration option) which promotes the netfilter
> > MARK value from the IPv6 packets to the sit packets.
> > Now I can mark packets using ip6tables, and on the ipv4 level I can still
> > differentiate between the priorities. Problem solved, I'm happy ;-)
> 
> I like this patch.  I think we should make it a kernel configuration
> option, but for all kind of tunnel interfaces.  Something like
> 'propagate NFMARK while tunneling' (or maybe 'preserve' instead of
> 'propagate' is better language?)

It certainly should be configurable. I've already sent it to the list, but
you can also download it from
http://dexter.hensema.net/~erik/patches/sit-promote-mark-2.4.21-pre4.diff

It should be easy to port this patch to gre and maybe ipip (don't know the
code of the latter, but I assume it's similar to gre and sit). I'll work on
that tomorrow, when I've got access to my development machine again.

In my current patch the configuration option is called 'IPv6: Promote
netfilter MARK value to sit packets'.
I don't think we should call it 'preserve', because technically that's not
what is happening. The tunnel interface creates a fresh new packet, with a
fresh new nfmark. Propagate seems to be the right term to me (as a
non-native english speaker).

-- 
Erik Hensema (erik@hensema.net)
