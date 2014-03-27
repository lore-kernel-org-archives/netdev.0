From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_conntrack: reserve two bytes for
 nf_ct_ext->len
Date: Thu, 27 Mar 2014 16:01:01 +0000
Message-ID: <20140327160100.GA32534@macbook.localnet>
References: <1395934354-13226-1-git-send-email-avagin@openvz.org>
 <20140327155033.GF21741@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Vagin <avagin@openvz.org>, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org, vvs@parallels.com,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140327155033.GF21741@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2014 at 04:50:33PM +0100, Florian Westphal wrote:
> Andrey Vagin <avagin@openvz.org> wrote:
> > "len" contains sizeof(nf_ct_ext) and size of extensions. In a worst
> > case it can contain all extensions. Bellow you can find sizes for all
> > types of extensions. Their sum is definitely bigger than 256.
> > 
> > nf_ct_ext_types[0]->len = 24
> > nf_ct_ext_types[1]->len = 32
> > nf_ct_ext_types[2]->len = 24
> > nf_ct_ext_types[3]->len = 32
> > nf_ct_ext_types[4]->len = 152
> 
> Guess its  the timer in the ecache extension (with LOCKDEP on probably).
> 
> I'll submit a patch to get rid of that shortly.
> 
> I think your patch is fine because the 'no timer
> in ecache extension' change is quite large, needs review/stress testing
> etc and is inapropriate for stable tree anyway.
> 
> > I have seen "len" up to 280 and my host has crashes w/o this patch.
> 
> ecache is 24 bytes without that timer, should be < 256 in total for
> all extensions.
> 
> I think BUILD_BUG_ON test would be nice.

We also have variable length extensions, but we definitely should catch
this *somewhere*.
