From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix wrong skb_get() usage / crash in
 IGMP/MLD parsing code
Date: Thu, 13 Aug 2015 17:11:01 -0700 (PDT)
Message-ID: <20150813.171101.925018652514860039.davem@davemloft.net>
References: <1439438047-19441-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org, bblanco@plumgrid.com,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	alexei.starovoitov@gmail.com
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1439438047-19441-1-git-send-email-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Thu, 13 Aug 2015 05:54:07 +0200

> The recent refactoring of the IGMP and MLD parsing code into
> ipv6_mc_check_mld() / ip_mc_check_igmp() introduced a potential crash=
 /
> BUG() invocation for bridges:
> =

> I wrongly assumed that skb_get() could be used as a simple reference
> counter for an skb which is not the case. skb_get() bears additional
> semantics, a user count. This leads to a BUG() invocation in
> pskb_expand_head() / kernel panic if pskb_may_pull() is called on an =
skb
> with a user count greater than one - unfortunately the refactoring di=
d
> just that.
> =

> Fixing this by removing the skb_get() call and changing the API: The
> caller of ipv6_mc_check_mld() / ip_mc_check_igmp() now needs to
> additionally check whether the returned skb_trimmed is a clone.
> =

> Fixes: 9afd85c9e455 ("net: Export IGMP/MLD message validation code")
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
> Signed-off-by: Linus L=FCssing <linus.luessing@c0d3.blue>

Applied, thanks.
