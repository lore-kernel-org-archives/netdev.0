From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [PATCH net-next 2/2] net/sched: act_csum: compute crc32c on
 SCTP packets
Date: Sun, 08 Jan 2017 17:43:43 +0100
Message-ID: <1483893823.2552.34.camel@redhat.com>
References: <cover.1483630849.git.dcaratti@redhat.com>
         <c9ee721fd7816b9d30939f23783f50f9aeb00d66.1483630849.git.dcaratti@redhat.com>
         <b4e2b22a-5a06-3c31-a312-3c6de1ef14e5@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com, Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51546 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756729AbdAHQnt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 11:43:49 -0500
In-Reply-To: <b4e2b22a-5a06-3c31-a312-3c6de1ef14e5@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-06 at 10:23 +0100, Nicolas Dichtel wrote:
> Le 05/01/2017 à 17:59, Davide Caratti a écrit :
> > @@ -21,7 +21,8 @@ enum {
> >  	TCA_CSUM_UPDATE_FLAG_IGMP    = 4,
> >  	TCA_CSUM_UPDATE_FLAG_TCP     = 8,
> >  	TCA_CSUM_UPDATE_FLAG_UDP     = 16,
> > -	TCA_CSUM_UPDATE_FLAG_UDPLITE = 32
> > +	TCA_CSUM_UPDATE_FLAG_UDPLITE = 32,
> > +	TCA_CSUM_UPDATE_FLAG_SCTP    = 64
> nit: please put a comma after the '64' so that the next person who adds
> a flag
> will not have to touch that line.
> 

ok,

> > @@ -365,6 +385,12 @@ static int tcf_csum_ipv4(struct sk_buff *skb, u32
> > update_flags)
> >  					       ntohs(iph->tot_len),
> > 1))
> >  				goto fail;
> >  		break;
> > +	case IPPROTO_SCTP:
> > +		if (update_flags & TCA_CSUM_UPDATE_FLAG_SCTP)
> > +			if (!tcf_csum_sctp(skb, iph->ihl * 4,
> > +					   ntohs(iph->tot_len)))
> nit: one 'if' only?
> 		if (update_flags & TCA_CSUM_UPDATE_FLAG_SCTP &&
> 		    !tcf_csum_sctp(skb, iph->ihl * 4, ntohs(iph->tot_len))
> 

ok,

> > @@ -481,6 +507,12 @@ static int tcf_csum_ipv6(struct sk_buff *skb, u32
> > update_flags)
> >  						       pl +
> > sizeof(*ip6h), 1))
> >  					goto fail;
> >  			goto done;
> > +		case IPPROTO_SCTP:
> > +			if (update_flags & TCA_CSUM_UPDATE_FLAG_SCTP)
> > +				if (!tcf_csum_sctp(skb, hl,
> > +						   pl +
> > sizeof(*ip6h)))
> Same here.
> 

ok,

> 
> Regards,
> Nicolas

hello Nicolas,
thank you for the attention! I will apply the changes you suggested and
repost a v2.

regards,
