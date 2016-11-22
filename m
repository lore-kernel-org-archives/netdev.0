From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net: l2tp: Treat NET_XMIT_CN as success in l2tp_eth_dev_xmit
Date: Mon, 21 Nov 2016 21:29:32 -0800
Message-ID: <CAM_iQpX-z8Eja4rPg5dzAXLXd6v3nwMMPev-gk+wM9XLBNYK1A@mail.gmail.com>
References: <1479689781-2125-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>, javier@osg.samsung.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Feng Gao <gfree.wind@gmail.com>
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36424 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755059AbcKVF3x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 00:29:53 -0500
Received: by mail-it0-f67.google.com with SMTP id n68so537833itn.3
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 21:29:53 -0800 (PST)
In-Reply-To: <1479689781-2125-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 20, 2016 at 4:56 PM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <gfree.wind@gmail.com>
>
> The tc could return NET_XMIT_CN as one congestion notification, but
> it does not mean the packe is lost. Other modules like ipvlan,
> macvlan, and others treat NET_XMIT_CN as success too.
> So l2tp_eth_dev_xmit should add the NET_XMIT_CN check.
>
> Signed-off-by: Gao Feng <gfree.wind@gmail.com>
> ---
>  net/l2tp/l2tp_eth.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
> index 965f7e3..3dc97b4 100644
> --- a/net/l2tp/l2tp_eth.c
> +++ b/net/l2tp/l2tp_eth.c
> @@ -97,7 +97,7 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>         unsigned int len = skb->len;
>         int ret = l2tp_xmit_skb(session, skb, session->hdr_len);
>
> -       if (likely(ret == NET_XMIT_SUCCESS)) {
> +       if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {

How could l2tp_xmit_skb() possibly return NET_XMIT_CN?
Note It ignores the return value of l2tp_xmit_core().
