From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Mon, 3 Oct 2016 12:45:00 -0700
Message-ID: <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com> <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34336 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751779AbcJCTpV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 15:45:21 -0400
Received: by mail-it0-f65.google.com with SMTP id j69so7548795itb.1
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 12:45:21 -0700 (PDT)
In-Reply-To: <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 29, 2016 at 4:03 AM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
>         skb2->skb_iif = skb->dev->ifindex;
>         skb2->dev = dev;
> -       err = dev_queue_xmit(skb2);
> +       if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
> +               err = dev_queue_xmit(skb2);
> +       else
> +               netif_receive_skb(skb2);

Any reason why not check the return value here?
