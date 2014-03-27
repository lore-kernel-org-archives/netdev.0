From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: reserve two bytes for
 nf_ct_ext->len
Date: Thu, 27 Mar 2014 16:50:33 +0100
Message-ID: <20140327155033.GF21741@breakpoint.cc>
References: <1395934354-13226-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, vvs@parallels.com,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1395934354-13226-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Vagin <avagin@openvz.org> wrote:
> "len" contains sizeof(nf_ct_ext) and size of extensions. In a worst
> case it can contain all extensions. Bellow you can find sizes for all
> types of extensions. Their sum is definitely bigger than 256.
> 
> nf_ct_ext_types[0]->len = 24
> nf_ct_ext_types[1]->len = 32
> nf_ct_ext_types[2]->len = 24
> nf_ct_ext_types[3]->len = 32
> nf_ct_ext_types[4]->len = 152

Guess its  the timer in the ecache extension (with LOCKDEP on probably).

I'll submit a patch to get rid of that shortly.

I think your patch is fine because the 'no timer
in ecache extension' change is quite large, needs review/stress testing
etc and is inapropriate for stable tree anyway.

> I have seen "len" up to 280 and my host has crashes w/o this patch.

ecache is 24 bytes without that timer, should be < 256 in total for
all extensions.

I think BUILD_BUG_ON test would be nice.
