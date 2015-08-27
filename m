From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v4 net-next 7/8] geneve: Consolidate Geneve functionality
 in single module.
Date: Wed, 26 Aug 2015 21:06:48 -0700
Message-ID: <CAEP_g=9mn5_+JZKSh06m9qCNGjL83uSja39J85gjS4GCyM33Vw@mail.gmail.com>
References: <1440626079-11689-1-git-send-email-pshelar@nicira.com>
 <1440626079-11689-8-git-send-email-pshelar@nicira.com> <CAEP_g=-YCEE_0h11vpwbdPQwRJoNgg7GvNr4xRMrBmu403BiPg@mail.gmail.com>
 <CALnjE+oYj=X0Vij_0StjDo7Cd9Fg++uh8EtSmnvYe4u3tOFhcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36344 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbbH0EHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 00:07:09 -0400
Received: by lbbpu9 with SMTP id pu9so3858071lbb.3
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 21:07:08 -0700 (PDT)
In-Reply-To: <CALnjE+oYj=X0Vij_0StjDo7Cd9Fg++uh8EtSmnvYe4u3tOFhcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 8:57 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Aug 26, 2015 at 8:08 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Wed, Aug 26, 2015 at 2:54 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>>> @@ -293,15 +615,13 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
>> [...]
>>> +               err = geneve_build_skb(rt, skb, key->tun_flags, vni,
>>> +                                      info->options_len, opts, udp_csum);
>>> +               if (unlikely(err))
>>> +                       goto err;
>> [...]
>>>  tx_error:
>>> -       dev->stats.tx_errors++;
>>>         dev_kfree_skb(skb);
>>> +err:
>>> +       dev->stats.tx_errors++;
>>>         return NETDEV_TX_OK;
>>>  }
>>
>> I'm not sure that it makes sense to break out these error conditions -
>> geneve_build_skb() doesn't free the skb, so it looks like there is a
>> leak on failure.
>
> It does frees skb. Which case are you looking at?

Never mind, you're right.
