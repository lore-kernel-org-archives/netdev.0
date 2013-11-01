From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net] net: flow_dissector: fail on evil iph->ihl
Date: Fri, 1 Nov 2013 16:29:27 +0000
Message-ID: <1383323367.1737.8.camel@bwh-desktop.uk.level5networks.com>
References: <1383289270-18952-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <edumazet@google.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Petr Matousek <pmatouse@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383289270-18952-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-01 at 15:01 +0800, Jason Wang wrote:
> We don't validate iph->ihl which may lead a dead loop if we meet a IPIP
> skb whose iph->ihl is zero. Fix this by failing immediately when iph->ihl
> is evil (less than 5).
> 
> This issue were introduced by commit ec5efe7946280d1e84603389a1030ccec0a767ae
> (rps: support IPIP encapsulation).

It would be helpful to include the CVE ID here:

CVE-2013-4348

Ben.

> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Petr Matousek <pmatouse@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> This patch is needed for stable.
> ---
>  net/core/flow_dissector.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 8d7d0dd..143b6fd 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -40,7 +40,7 @@ again:
>  		struct iphdr _iph;
>  ip:
>  		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
> -		if (!iph)
> +		if (!iph || iph->ihl < 5)
>  			return false;
>  
>  		if (ip_is_fragment(iph))

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
