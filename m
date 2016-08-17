From: Marco Grassi <marco.gra@gmail.com>
Subject: Re: Fw: Linux tcp_xmit_retransmit_queue use after free on 4.8-rc1 / master]
Date: Wed, 17 Aug 2016 19:10:15 +0800
Message-ID: <CAFkTriKbQz43Mt7wtHPTzkeszTUvKqCGOLmgCWVikNYnMC_New@mail.gmail.com>
References: <20160816104551.GA28052@kroah.com> <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXV-jV0FsAzxt4JYrc6d5LCCLt-5_0uMvM49sV8-+SDDQ@mail.gmail.com>
 <1471379279.4943.14.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpW46DkWU2COW6tXUj3W==WQVkHT--qW8Hfus5ZiiKtYvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36529 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbcHQLVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 07:21:52 -0400
Received: by mail-it0-f68.google.com with SMTP id j124so8683268ith.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 04:21:52 -0700 (PDT)
In-Reply-To: <CAM_iQpW46DkWU2COW6tXUj3W==WQVkHT--qW8Hfus5ZiiKtYvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, I'm fuzzing with your patch applied, and I don't see the issue
triggering anymore, (or other related)

I will keep you updated if something pops up, so we can fix before pushing

Marco

On Wed, Aug 17, 2016 at 4:32 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Aug 16, 2016 at 1:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> And tcp_add_write_queue_tail() looks like :
>>
>>
>> static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
>> {
>>         __tcp_add_write_queue_tail(sk, skb);
>>
>>         /* Queue it, remembering where we must start sending. */
>>         if (sk->sk_send_head == NULL) {
>>                 sk->sk_send_head = skb;
>>
>>                 if (tcp_sk(sk)->highest_sack == NULL)
>>                         tcp_sk(sk)->highest_sack = skb;
>>         }
>> }
>>
>
> Ah, I never looked into tcp_add_write_queue_tail()...
>
> So this bug seems exist after commit 6859d49475d4f32abe640372117e4b...
