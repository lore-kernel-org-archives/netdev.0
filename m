From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [patch net-next v2 1/4] openvswitch: actions: use
 skb_postpull_rcsum when possible
Date: Wed, 12 Nov 2014 11:13:29 -0800
Message-ID: <CALnjE+qX9M_1UuyMKD9CaSmTUSY-GtyWgW8dZHzY+294fv9=Hg@mail.gmail.com>
References: <1415803950-9838-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, Thomas Graf <tgraf@suug.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:50861 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753144AbaKLTNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 14:13:31 -0500
Received: by mail-ie0-f180.google.com with SMTP id y20so14364723ier.11
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 11:13:29 -0800 (PST)
In-Reply-To: <1415803950-9838-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2014 at 6:52 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Replace duplicated code by calling skb_postpull_rcsum
>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
>  net/openvswitch/actions.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 394efa6..749a301 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -175,10 +175,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>         if (unlikely(err))
>                 return err;
>
> -       if (skb->ip_summed == CHECKSUM_COMPLETE)
> -               skb->csum = csum_sub(skb->csum,
> -                                    csum_partial(skb_mpls_header(skb),
> -                                                 MPLS_HLEN, 0));
> +       skb_postpull_rcsum(skb, skb_mpls_header(skb), MPLS_HLEN);
>
>         memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
>                 skb->mac_len);
> @@ -230,9 +227,7 @@ static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
>         if (unlikely(err))
>                 return err;
>
> -       if (skb->ip_summed == CHECKSUM_COMPLETE)
> -               skb->csum = csum_sub(skb->csum, csum_partial(skb->data
> -                                       + (2 * ETH_ALEN), VLAN_HLEN, 0));
> +       skb_postpull_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
>
>         vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
>         *current_tci = vhdr->h_vlan_TCI;
> --
> 1.9.3
>
