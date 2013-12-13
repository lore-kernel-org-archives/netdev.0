From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: fix headroom calculation in udp6_ufo_fragment
Date: Fri, 13 Dec 2013 15:12:27 +0100
Message-ID: <20131213141227.GC7332@order.stressinduktion.org>
References: <D00A5DFD97C44C4D820FC3A847C5D5750730630F@IRVEXCHMB14.corp.ad.broadcom.com> <20131213133453.GB7332@order.stressinduktion.org> <20131213134205.GB11044@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Mark Hambleton <mark.hambleton@broadcom.com>,
	'Pravin B Shelar' <pshelar@nicira.com>,
	'Saran Neti' <Saran.Neti@telus.com>,
	"'David S. Miller'" <davem@davemloft.net>,
	'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'stable@vger.kernel.org'" <stable@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131213134205.GB11044@sirena.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 13, 2013 at 01:42:05PM +0000, Mark Brown wrote:
> On Fri, Dec 13, 2013 at 02:34:53PM +0100, Hannes Frederic Sowa wrote:
> 
> > Sorry, I don't know which version the LTS kernel is. Upstream does not use
> > sk_buff_data_t for mac_header any more.
> 
> This is with v3.10.

The change happend in 3.11. So I guess it was an oversight while backporting.
Following patch should help and should get backported to all stable kernels
<= 3.10.

[PATCH stable] ipv6: fix illegal mac_header comparison on 32bit

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Patch intended for stable kernel <= 3.10.

 net/ipv6/udp_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index e7359f9..e15a357 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -90,7 +90,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 
 		/* Check if there is enough headroom to insert fragment header. */
 		tnl_hlen = skb_tnl_header_len(skb);
-		if (skb->mac_header < (tnl_hlen + frag_hdr_sz)) {
+		if (skb_mac_header(skb) < skb->head + tnl_hlen + frag_hdr_sz) {
 			if (gso_pskb_expand_head(skb, tnl_hlen + frag_hdr_sz))
 				goto out;
 		}
-- 
1.8.3.1
