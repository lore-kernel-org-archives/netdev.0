From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Fri, 26 Aug 2016 09:16:21 +0300
Message-ID: <CAJ3xEMjg8+EA8SwNyT-u_R7he9toRqcDuS5mBzGZuGbUfOE9YA@mail.gmail.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
 <1472141627-27339-5-git-send-email-hadarh@mellanox.com> <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36150 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757346AbcHZGQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 02:16:22 -0400
Received: by mail-oi0-f67.google.com with SMTP id b22so6194577oii.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 23:16:22 -0700 (PDT)
In-Reply-To: <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 8:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-08-25 at 19:13 +0300, Hadar Hen Zion wrote:
>> From: Amir Vadai <amir@vadai.me>

>> +static int tunnel_key_act(struct sk_buff *skb, const struct tc_action *a,
>> +                       struct tcf_result *res)
>> +{
>> +     struct tcf_tunnel_key *t = to_tunnel_key(a);
>> +     int action;
>> +
>> +     spin_lock(&t->tcf_lock);
>> +     tcf_lastuse_update(&t->tcf_tm);
>> +     bstats_update(&t->tcf_bstats, skb);
>> +     action = t->tcf_action;
>> +
>> +     switch (t->tcft_action) {
>> +     case TCA_TUNNEL_KEY_ACT_RELEASE:
>> +             skb_dst_set_noref(skb, NULL);
>> +             break;
>> +     case TCA_TUNNEL_KEY_ACT_SET:
>> +             skb_dst_set_noref(skb, &t->tcft_enc_metadata->dst);
>> +             break;
>> +     default:
>> +             WARN_ONCE(1, "Bad tunnel_key action.\n");
>> +             break;
>> +     }
>> +
>> +     spin_unlock(&t->tcf_lock);
>> +     return action;

> Please find a better way than using a spinlock in this hot path.
> Maybe looking at
> 2ee22a90c7afac265bb6f7abea610b938195e2b8 net_sched: act_mirred: remove spinlock in fast path
[...]

okay, thanks for the heads up, will look there
