From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Route cache performance under stress
Date: Mon, 26 May 2003 11:29:02 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <87y90u5a5d.fsf@deneb.enyo.de>
References: <20030520011053.GB10419@netnation.com>
	<20030519.181405.35017608.davem@redhat.com>
	<20030521000936.GA19077@netnation.com>
	<20030520.171358.28794219.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sim@netnation.com, hadi@shell.cyberus.ca, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030520.171358.28794219.davem@redhat.com> (David S. Miller's
 message of "Tue, 20 May 2003 17:13:58 -0700 (PDT)")
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

>    From: Simon Kirby <sim@netnation.com>
>    Date: Tue, 20 May 2003 17:09:36 -0700
>    
>    It's rather difficult to follow, but I don't see any "h4r h4r, expl0it
>    th3 L1nux h4sh" comments or anything in the code that seems to attempt to
>    exploit the hash algorithms in (older) Linux.
>
> Look at the vc[] table and how it uses this in rndip().

The vc[] table is used to generate packets which don't fall victim to
widely implemented source address checks (e.g. "ip verify unicast
source reachable-via any" on recent Cisco routers).

I've checked the generated packets and they appear to be distributed
rather evenly among about 3,000 of the 8,192 hash buckets (with the
old hash function, of course), so juno-z.101f.c does not specifically
choose source addresses to trigger collisions.

(BTW, that's the reason why I consider the hash collision DoS attack
not too relevant in practice -- anybody who wants to DoS my machine
can probably send lots of packets to it.  juno-z.101f.c just works
well enough, even if it doesn't saturate all available bandwidth.)
