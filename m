From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] tcp: avoid order-1 allocations on wifi and tx path
Date: Wed, 11 Apr 2012 09:38:02 +0200
Message-ID: <1334129882.5300.2539.camel@edumazet-glaptop>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
	 <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org>
	 <1334122980.5300.2154.camel@edumazet-glaptop>
	 <1334125848.5300.2330.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334125848.5300.2330.camel@edumazet-glaptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-04-11 at 08:30 +0200, Eric Dumazet wrote:
> Marc Merlin reported many order-1 allocations failures in TX path on its
> wireless setup, that dont make any sense with MTU=1500 network, and non
> SG capable hardware.
> 
> After investigation, it turns out TCP uses sk_stream_alloc_skb() and
> used as a convention skb_tailroom(skb) to know how many bytes of data
> payload could be put in this skb (for non SG capable devices)
> 
...
> 
> Reported-by: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
> Tested-by: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

David, I forgot to say this should be backported to 3.2 & 3.3

commit 87fb4b7b533073 (net: more accurate skb truesize) did the
placement of skb_shared_info at the end of skb head, so
sk_stream_alloc_skb() had to reserve more room so that tailroom stayed
at MSS



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
