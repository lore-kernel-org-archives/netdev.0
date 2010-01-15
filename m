From: Andrew May <acmay@acmay.org>
Subject: Re: [PATCH 7/7] Staging: Octeon Ethernet: Use constants from in.h
Date: Thu, 14 Jan 2010 23:29:00 -0800
Message-ID: <20100114232900.55111058@mud>
References: <4B463005.8060505@caviumnetworks.com>
        <1262891106-32146-7-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
        netdev@vger.kernel.org, gregkh@suse.de
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1262891106-32146-7-git-send-email-ddaney@caviumnetworks.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Thu,  7 Jan 2010 11:05:06 -0800
David Daney <ddaney@caviumnetworks.com> wrote:

> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
> ---
>  drivers/staging/octeon/ethernet-defines.h |    3 ---
>  drivers/staging/octeon/ethernet-tx.c      |    8 ++++----
>  2 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/staging/octeon/ethernet-defines.h
> b/drivers/staging/octeon/ethernet-defines.h index 9c4910e..00a8561
> 100644 --- a/drivers/staging/octeon/ethernet-defines.h
> +++ b/drivers/staging/octeon/ethernet-defines.h
> @@ -98,9 +98,6 @@
>  #define MAX_SKB_TO_FREE 10
>  #define MAX_OUT_QUEUE_DEPTH 1000
>  
> -#define IP_PROTOCOL_TCP             6
> -#define IP_PROTOCOL_UDP             0x11
> -
>  #define FAU_NUM_PACKET_BUFFERS_TO_FREE (CVMX_FAU_REG_END -
> sizeof(uint32_t)) #define TOTAL_NUMBER_OF_PORTS
> (CVMX_PIP_NUM_INPUT_PORTS+1) 
> diff --git a/drivers/staging/octeon/ethernet-tx.c
> b/drivers/staging/octeon/ethernet-tx.c index bc67e41..62258bd 100644
> --- a/drivers/staging/octeon/ethernet-tx.c
> +++ b/drivers/staging/octeon/ethernet-tx.c
> @@ -359,8 +359,8 @@ dont_put_skbuff_in_hw:
>  	if (USE_HW_TCPUDP_CHECKSUM && (skb->protocol ==
> htons(ETH_P_IP)) && (ip_hdr(skb)->version == 4) && (ip_hdr(skb)->ihl
> == 5) && ((ip_hdr(skb)->frag_off == 0) || (ip_hdr(skb)->frag_off == 1
> << 14))
> -	    && ((ip_hdr(skb)->protocol == IP_PROTOCOL_TCP)
> -		|| (ip_hdr(skb)->protocol == IP_PROTOCOL_UDP))) {
> +	    && ((ip_hdr(skb)->protocol == IPPROTO_TCP)
> +		|| (ip_hdr(skb)->protocol == IPPROTO_UDP))) {
>  		/* Use hardware checksum calc */
>  		pko_command.s.ipoffp1 = sizeof(struct ethhdr) + 1;
>  	}

Why isn't skb->ip_summed checked here instead? It seems like the csum
calculation needs to be skipped by the stack if this is actually going
to help performance.

And does this end up re-writing a bad checksum on a routed packet, back
to being a good checksum?
