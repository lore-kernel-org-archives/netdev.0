From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 2/2] net: Export IGMP/MLD message
 validation code
Date: Tue, 14 Apr 2015 14:27:07 -0400 (EDT)
Message-ID: <20150414.142707.472821254273583286.davem@davemloft.net>
References: <1428993462-6079-1-git-send-email-linus.luessing@c0d3.blue>
	<1428993462-6079-3-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org, linux-kernel@vger.kernel.org,
	therbert@google.com
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1428993462-6079-3-git-send-email-linus.luessing@c0d3.blue>
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
Date: Tue, 14 Apr 2015 08:37:42 +0200

> +int skb_checksum_trimmed(struct sk_buff *skb, unsigned int transport=
_len,
> +			 __sum16(*skb_check_func)(struct sk_buff *skb),
> +			 struct sk_buff **skb_trimmed)
> +{

This is a really terrible interface.

It is designed in such a way that it is completely ambiguous who is
resonsible for managing the lifetimes of 'skb' and 'skb_trimmed'.

I would suggest changing this such that:

1) If you clone successfully, 'skb' is released.

2) whatever SKB ends up being used is returned as an error pointer.

3) The caller is responsible for freeing or grabbing a reference
   to the skb returned.

Also, this is taking too long to finalize and we are past the openning
of the merge window so you will have to submit a fixed up version when
the net-next tree opens up for submissions as it is very strongly
closed right now.

Thanks.
