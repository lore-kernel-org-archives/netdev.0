From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Patch] net: fix a wrong assignment in skb_split()
Date: Wed, 20 Feb 2013 10:42:18 -0800
Message-ID: <CALnjE+rwqV_APx-epsaiF6KjvjSmXU=iORwVyNov8Zvk9we0HQ@mail.gmail.com>
References: <1361350290-28581-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:33484 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934152Ab3BTSmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 13:42:19 -0500
Received: by mail-ye0-f200.google.com with SMTP id r13so10899206yen.11
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2013 10:42:18 -0800 (PST)
In-Reply-To: <1361350290-28581-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2013 at 12:51 AM, Cong Wang <amwang@redhat.com> wrote:
> commit c9af6db4c11ccc6c3e7f1 (net: Fix possible wrong checksum generation)
> has a suspicous piece:
>
>         -       skb_shinfo(skb1)->gso_type = skb_shinfo(skb)->gso_type;
>         -
>         +       skb_shinfo(skb)->tx_flags = skb_shinfo(skb1)->tx_flags & SKBTX_SHARED_FRAG;
>
> skb1 is the new skb, therefore should be on the left side of the assignment.
> This patch fixes it.
>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
Looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 2a3ca33..33245ef 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2326,7 +2326,7 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
>  {
>         int pos = skb_headlen(skb);
>
> -       skb_shinfo(skb)->tx_flags = skb_shinfo(skb1)->tx_flags & SKBTX_SHARED_FRAG;
> +       skb_shinfo(skb1)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
>         if (len < pos)  /* Split line is inside header. */
>                 skb_split_inside_header(skb, skb1, len, pos);
>         else            /* Second chunk has no header, nothing to copy. */
