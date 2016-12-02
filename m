From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Fri, 2 Dec 2016 11:24:50 +0100
Message-ID: <20161202112450.1720d33d@redhat.com>
References: <20161201091108.GF26507@breakpoint.cc>
        <20161201145834.GA569@pox.localdomain>
        <7e2be2fc-7c04-b333-59c7-43d4fcfcb451@stressinduktion.org>
        <20161201162814.GA31300@pox.localdomain>
        <583b8947-3395-8529-933b-08e1a86a0778@stressinduktion.org>
        <CALx6S36=Y0dSux+-omWXZKtxb73_g4+DXhPBawb79+UF6rp9rw@mail.gmail.com>
        <9b4264f8-26b9-a611-56f0-0840cecf9c44@stressinduktion.org>
        <CALx6S34+Brx-JERLhexxv9CGE9moH_Pi-H_OK=hQ-iJ2g2yYgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Thomas Graf <tgraf@suug.ch>, Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35158 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757442AbcLBKYz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:24:55 -0500
In-Reply-To: <CALx6S34+Brx-JERLhexxv9CGE9moH_Pi-H_OK=hQ-iJ2g2yYgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Dec 2016 13:51:32 -0800
Tom Herbert <tom@herbertland.com> wrote:

> >> The technical plenary at last IETF on Seoul a couple of weeks ago was
> >> exclusively focussed on DDOS in light of the recent attack against
> >> Dyn. There were speakers form Cloudflare and Dyn. The Cloudflare
> >> presentation by Nick Sullivan
> >> (https://www.ietf.org/proceedings/97/slides/slides-97-ietf-sessb-how-to-stay-online-harsh-realities-of-operating-in-a-hostile-network-nick-sullivan-01.pdf)
> >> alluded to some implementation of DDOS mitigation. In particular, on
> >> slide 6 Nick gave some numbers for drop rates in DDOS. The "kernel"

slide 14

> >> numbers he gave we're based in iptables+BPF and that was a whole
> >> 1.2Mpps-- somehow that seems ridiculously to me (I said so at the mic
> >> and that's also when I introduced XDP to whole IETF :-) ). If that's
> >> the best we can do the Internet is in a world hurt. DDOS mitigation
> >> alone is probably a sufficient motivation to look at XDP. We need
> >> something that drops bad packets as quickly as possible when under
> >> attack, we need this to be integrated into the stack, we need it to be
> >> programmable to deal with the increasing savvy of attackers, and we
> >> don't want to be forced to be dependent on HW solutions. This is why
> >> we created XDP!  

The 1.2Mpps number is a bit low, but we are unfortunately in that
ballpark.

> > I totally understand that. But in my reply to David in this thread I
> > mentioned DNS apex processing as being problematic which is actually
> > being referred in your linked slide deck on page 9 ("What do floods look
> > like") and the problematic of parsing DNS packets in XDP due to string
> > processing and looping inside eBPF.

That is a weak argument. You do realize CloudFlare actually use eBPF to
do this exact filtering, and (so-far) eBPF for parsing DNS have been
sufficient for them.

> I agree that eBPF is not going to be sufficient from everything we'll
> want to do. Undoubtably, we'll continue see new addition of more
> helpers to assist in processing, but at some point we will want a to
> load a kernel module that handles more complex processing and insert
> it at the XDP callout. Nothing in the design of XDP precludes doing
> that and I have already posted the patches to generalize the XDP
> callout for that. Taking either of these routes has tradeoffs, but
> regardless of whether this is BPF or module code, the principles of
> XDP and its value to help solve some class of problems remains.

As I've said before, I do support Tom's patches for a more generic XDP
hook that the kernel itself can use.  The first thing I would implement
with this is a fast-path for Linux L2 bridging (do depend on multiport
TX support). It would be so easy to speedup bridging, XDP would only
need to forward packets already in the bridge-FIB table, rest is
XDP_PASS to normal stack and bridge code (timers etc).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
