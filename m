From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH/RFC net-next v2 4/4] net/sched: cls_flower: allow control
 of tree traversal on packet parse errors
Date: Fri, 5 May 2017 15:44:58 -0700
Message-ID: <CAM_iQpUY0Kj8oqYGGa-GB7LxaGKz1La1BkMfeCfFXGWKkPSyEA@mail.gmail.com>
References: <1493988426-22854-1-git-send-email-simon.horman@netronome.com> <1493988426-22854-5-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Benjamin LaHaise <benjamin.lahaise@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37560 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754170AbdEEWpU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 18:45:20 -0400
Received: by mail-wm0-f53.google.com with SMTP id m123so17771869wma.0
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 15:45:20 -0700 (PDT)
In-Reply-To: <1493988426-22854-5-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 5, 2017 at 5:47 AM, Simon Horman <simon.horman@netronome.com> wrote:
>
>  # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
>  # tc filter add dev eth0 protocol ip parent ffff: flower \
>        indev eth0 ip_proto udp dst_port 80 truncated drop action continue
>
[...]
> @@ -188,7 +189,7 @@ static int fl_classify(struct sk_buff *skb, const struct tcf_proto *tp,
>          */
>         skb_key.basic.n_proto = skb->protocol;
>         if (!skb_flow_dissect(skb, &head->dissector, &skb_key, 0))
> -               return -1;
> +               return head->err_action;

This design looks odd, if you consider matching truncated packets as
a filter like other normal filters, then you should rely on the action
appended to return the action code, not within the filter itself.
