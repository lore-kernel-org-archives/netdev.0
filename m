From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Sun, 8 Feb 2004 23:38:12 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402082322140.6268@u.domain.uli>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
 <20040208131417.4f8693de.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040208131417.4f8693de.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sun, 8 Feb 2004, David S. Miller wrote:

> This is a dicey situation in that when the entry does become
> valid this does not trigger a proxy arp by us, does it?

	Yes, currently it works in this way, when target
replies we do not propagate this answer to the proxy_queue.
But this is not fatal becuase we apply delay in the answer
which means we have time to resolve the target. If we do not
have answer in that time we simply drop the skb from proxy_queue.
The requestor can send next requests and we reply each that
request only if the target is in valid state.

> I guess the original requestor will redo the request, so I'm

	Yes, the skbs from proxy_queue are removed in time, they
do not stay there until we have answer for them.

> just mentioning this in passing.  This is an area where admittedly
> I'm not well versed.
>
> So proxy ARP experts speak up :)

	Yep, lets see what Alexey and other gurus think

Regards

--
Julian Anastasov <ja@ssi.bg>
