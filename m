From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: fix wrong skb_get() usage / crash in IGMP/MLD
 parsing code
Date: Wed, 12 Aug 2015 21:55:50 -0700
Message-ID: <20150813045549.GA60201@Alexeis-MBP.westell.com>
References: <1439438047-19441-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Brenden Blanco <bblanco@plumgrid.com>
To: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439438047-19441-1-git-send-email-linus.luessing@c0d3.blue>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2015 at 05:54:07AM +0200, Linus L=FCssing wrote:
> The recent refactoring of the IGMP and MLD parsing code into
> ipv6_mc_check_mld() / ip_mc_check_igmp() introduced a potential crash=
 /
> BUG() invocation for bridges:
>=20
> I wrongly assumed that skb_get() could be used as a simple reference
> counter for an skb which is not the case. skb_get() bears additional
> semantics, a user count. This leads to a BUG() invocation in
> pskb_expand_head() / kernel panic if pskb_may_pull() is called on an =
skb
> with a user count greater than one - unfortunately the refactoring di=
d
> just that.
>=20
> Fixing this by removing the skb_get() call and changing the API: The
> caller of ipv6_mc_check_mld() / ip_mc_check_igmp() now needs to
> additionally check whether the returned skb_trimmed is a clone.
>=20
> Fixes: 9afd85c9e455 ("net: Export IGMP/MLD message validation code")
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
> Signed-off-by: Linus L=FCssing <linus.luessing@c0d3.blue>

I think the fix actually made the code easier to read.
Thank you. Looks good to me.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
