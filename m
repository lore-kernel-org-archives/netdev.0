From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skb_checksum_help() vs GSO
Date: Thu, 12 Jan 2012 14:10:17 -0800
Message-ID: <20120112141017.0a83e973@nehalam.linuxnetplumber.net>
References: <1326400930.2740.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1326400930.2740.10.camel@bwh-desktop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jan 2012 20:42:10 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> skb_checksum_help() does:
> 
> 	if (unlikely(skb_shinfo(skb)->gso_size)) {
> 		/* Let GSO fix up the checksum. */
> 		goto out_set_summed;
> 	}
> ...
> out_set_summed:
> 	skb->ip_summed = CHECKSUM_NONE;
> out:
> 	return ret;
> 
> but skb_gso_segment() requires that skb->ip_summed == CHECKSUM_PARTIAL
> and WARNs if not.  I don't think there's any case where it's valid to
> call both.  Shouldn't skb_checksum_help() also WARN and return an error
> code instead of muddling on?
> 
> Inspecting the callers of skb_checksum_help(), it looks like sch_netem's
> 'corrupt' option and xt_CHECKSUM might trigger this case.
> 
> Ben.

Netem needs to check for GSO manually segment before calling skb_checksum_help.
I'll sort it out.
