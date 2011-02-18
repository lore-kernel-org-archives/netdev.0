From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] tproxy: do not assign timewait sockets to skb->sk
Date: Fri, 18 Feb 2011 17:19:25 +0100
Message-ID: <4D5E9C0D.7030202@trash.net>
References: <1297683874-10188-1-git-send-email-fw@strlen.de> <1297972902.2253.51.camel@Nokia-N900-51-1> <20110217205249.GF8821@Chamillionaire.breakpoint.cc> <1297976642.3789.5.camel@Nokia-N900-51-1> <20110217212717.GG8821@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	KOVACS Krisztian <hidden@balabit.hu>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110217212717.GG8821@Chamillionaire.breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 17.02.2011 22:27, schrieb Florian Westphal:
> Balazs Scheidler <bazsi@balabit.hu> wrote:
>> the destination port in the packet can be different in the two lookups. --on-port tproxy option.
> 
> Hrm...  The initial lookup uses the header ip addresses:
>         sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
>                                    iph->saddr, iph->daddr,
>                                    hp->source, hp->dest,
>                                    skb->dev, NFT_LOOKUP_ESTABLISHED);
> 
> 3 possible cases:
> - no socket -- try to find listener. This case is not changed by my patch.
> - sk is normal socket. set nfmark and skb->sk. Also not changed.
> - sk is in TW state. This is not changed either:
> 	tproxy_handle_time_wait4() will check if this is a SYN. If it is, a new
> 	listener lookup is made, and TW socket is kicked out.
> 
> If the packet is not a SYN, then tproxy_handle_time_wait4() won't do anything.
> Previously, the timewait sk would now be assigned to skb->sk, which my patch
> prevents.  But I don't see where the '--on-port' port number is involved in the
> TW socket lookup?
> 
> Thanks for reviwing the patch!

For some reason I've not received Balazs' email. Balazs, I'm about to
submit my queued patches upstream, if you wish to object to this patch,
please do so now.

Thanks.
