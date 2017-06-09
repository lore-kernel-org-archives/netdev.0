From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] net/flow: fix fc->percpu NULL pointer dereference
Date: Fri, 9 Jun 2017 20:29:06 +0800
Message-ID: <20170609122906.GD12974@leo.usersys.redhat.com>
References: <1496996036-22077-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JSeKnspZpnWTXsze7sCSXJ9mbq2K3-mu-muuy8iT4A1qw@mail.gmail.com>
 <20170609083255.GR22049@secunet.com>
 <CADvbK_dn9QMd8_yRsBMZnjstxjy_L-Pc_UPkyNbyZ=0OORu85A@mail.gmail.com>
 <CAPwn2JR8MUauO44qAeb3tw93PuQHEbO_8Tocs-ZW8Y9ZK+Ln8A@mail.gmail.com>
 <CADvbK_c=ZrFAKeaTvM2PBGbAOO4_38v4S4QB93QChUO0nK2zHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33495 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdFIM3R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 08:29:17 -0400
Received: by mail-pg0-f66.google.com with SMTP id a70so7573403pge.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 05:29:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CADvbK_c=ZrFAKeaTvM2PBGbAOO4_38v4S4QB93QChUO0nK2zHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 09, 2017 at 05:49:50PM +0800, Xin Long wrote:
> another fix is to move xfrm_garbage_collect out of xfrm_policy_flush.
> I could only see two places need to call it.
> something like:
> 
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -2755,6 +2755,8 @@ static int pfkey_spdflush(struct sock *sk,
> struct sk_buff *skb, const struct sad
>         int err, err2;
> 
>         err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, true);
> +       if (!err)
> +               xfrm_garbage_collect(net);
>         err2 = unicast_flush_resp(sk, hdr);
>         if (err || err2) {
>                 if (err == -ESRCH) /* empty table - old silent behavior */

Hmm, that would be better, just the xfrm_garbage_collect() need to be after
err || err2 check

+          xfrm_garbage_collect(net);

I will send v2 patch.

Thanks
Hangbin
