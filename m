From: Andi Kleen <ak@suse.de>
Subject: Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 09:25:19 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030611072519.GB27144@wotan.suse.de>
References: <20030610.152020.59678979.davem@redhat.com> <Pine.LNX.4.51.0306101956520.7801@ns.istop.com> <3EE67D2D.80608@candelatech.com> <20030610.180120.71112140.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, ralph+d@istop.com,
	Robert.Olsson@data.slu.se, hadi@shell.cyberus.ca, xerox@foonet.net,
	sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030610.180120.71112140.davem@redhat.com>
List-Id: netdev.vger.kernel.org

> I have a strange feeling that Ralph's system isn't using
> TSC and that's why it shows up so high on the profiles :-)
> TSC do_gettimeofday() is REALLY cheap (TSC read plus a multiply which
> x86 does in like 5 cycles).

On a P4 rdtsc takes 90+ cycles (probably because it's flushing the complete
pipeline). Of course it's still relatively fast if you run that at 3Ghz,
but on slower P4s it may hurt.

On Athlons/Hammers it is quite fast, but at least on Hammer it needs
a pipeline flush again for accuracy (otherwise the CPU can speculate
it around)

One bigger cost is normally the rw lock or the two memory barriers for
the seqlock (on 2.5). On a UP compiled kernel it should not be a problem
though.

-Andi
