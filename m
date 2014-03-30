From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_conntrack: reserve two bytes for
 nf_ct_ext->len (v3)
Date: Sun, 30 Mar 2014 13:35:04 +0200
Message-ID: <20140330113504.GA5895@localhost>
References: <20140328092449.GA20844@paralelels.com>
 <1396000472-6130-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, vvs@parallels.com,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1396000472-6130-1-git-send-email-avagin@openvz.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 28, 2014 at 01:54:32PM +0400, Andrey Vagin wrote:
> "len" contains sizeof(nf_ct_ext) and size of extensions. In a worst
> case it can contain all extensions. Bellow you can find sizes for all
> types of extensions. Their sum is definitely bigger than 256.
> 
> nf_ct_ext_types[0]->len = 24
> nf_ct_ext_types[1]->len = 32
> nf_ct_ext_types[2]->len = 24
> nf_ct_ext_types[3]->len = 32
> nf_ct_ext_types[4]->len = 152
> nf_ct_ext_types[5]->len = 2
> nf_ct_ext_types[6]->len = 16
> nf_ct_ext_types[7]->len = 8
> 
> I have seen "len" up to 280 and my host has crashes w/o this patch.
> 
> The right way to fix this problem is reducing the size of the ecache
> extension (4) and Florian is going to do this, but these changes will
> be quite large to be appropriate for a stable tree.
> 
> v2: rearrange the extension so ECACHE comes last. This is required to
> prevent overflow of nf_ct_ext->offset.
> v3: The previous attempt of rearranging constants doesn't work here,
> because extensions may be added in a random order.

Applied, thanks.
