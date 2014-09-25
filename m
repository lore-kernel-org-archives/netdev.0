From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] neigh: check error pointer instead of NULL for ipv4_neigh_lookup()
Date: Thu, 25 Sep 2014 08:35:03 -0700
Message-ID: <CAADnVQ+=yuG0+0kSj291MbbxMRvmeYN7D_2PkJsjkLWtnkt4WQ@mail.gmail.com>
References: <1411603673-19084-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:35296 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbaIYPfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 11:35:05 -0400
Received: by mail-qc0-f175.google.com with SMTP id o8so5184814qcw.34
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 08:35:03 -0700 (PDT)
In-Reply-To: <1411603673-19084-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 5:07 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Fixes: commit f187bc6efb7250afee0e2009b6106 ("ipv4: No need to set generic neighbour pointer")
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv4/route.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 173e7ea..cbadb94 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -746,7 +746,7 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
>         }
>
>         n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
> -       if (n) {
> +       if (!IS_ERR(n)) {
>                 if (!(n->nud_state & NUD_VALID)) {
>                         neigh_event_send(n, NULL);

assuming symptoms of this was a crash?
Could you share the stack trace to see how we got to this state ?
Or was it spotted just by code inspection?

Thanks!
