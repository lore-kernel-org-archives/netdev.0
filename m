From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: h323: bug in parsing of ASN1 SEQOF field
Date: Tue, 22 Mar 2011 19:33:49 -0700 (PDT)
Message-ID: <20110322.193349.102533280.davem@davemloft.net>
References: <1300794929-1541-1-git-send-email-dsterba@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org, netfilter-@vger.kernel.org, kaber@trash.net
To: dsterba@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300794929-1541-1-git-send-email-dsterba@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Sterba <dsterba@suse.cz>
Date: Tue, 22 Mar 2011 12:55:29 +0100

> Static analyzer of clang found a dead store which appears to be a bug in
> reading count of items in SEQOF field, only the lower byte of word is
> stored. This may lead to corrupted read and communication shutdown.
> 
> The bug has been in the module since it's first inclusion into linux
> kernel.
> 
> Signed-off-by: David Sterba <dsterba@suse.cz>

Please send netfilter patches to the listed netfilter maintainer
and appropriate mailing lists.  I've added them to the CC:

Otherwise your patch will not be looked at by the right people.

> CC: David Miller <davem@davemloft.net>
> CC: netdev@vger.kernel.org
> CC: stable@kernel.org
> ---
>  net/netfilter/nf_conntrack_h323_asn1.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
> index 8678823..bcd5ed6 100644
> --- a/net/netfilter/nf_conntrack_h323_asn1.c
> +++ b/net/netfilter/nf_conntrack_h323_asn1.c
> @@ -631,7 +631,7 @@ static int decode_seqof(bitstr_t *bs, const struct field_t *f,
>  		CHECK_BOUND(bs, 2);
>  		count = *bs->cur++;
>  		count <<= 8;
> -		count = *bs->cur++;
> +		count += *bs->cur++;
>  		break;
>  	case SEMI:
>  		BYTE_ALIGN(bs);
> -- 
> 1.7.4.1.176.g501cc
> 
