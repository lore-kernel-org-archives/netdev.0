From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Mon, 6 Jun 2016 12:52:19 -0700
Message-ID: <CAM_iQpXJAa5B=4ez9z+-Q66rFj+EUTGwrYWMhYoCK=3rp65gYw@mail.gmail.com>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
 <CAM_iQpWDc1JAa9MhcSAOdJVVRoG52Z+p47CD-rd81LzN28zk1A@mail.gmail.com> <5755CE3A.7050002@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34738 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbcFFTwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 15:52:40 -0400
Received: by mail-yw0-f193.google.com with SMTP id j74so20408020ywg.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 12:52:39 -0700 (PDT)
In-Reply-To: <5755CE3A.7050002@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 6, 2016 at 12:25 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 06/06/2016 07:12 PM, Cong Wang wrote:
>>
>> On Sat, Jun 4, 2016 at 9:24 AM, Daniel Borkmann <daniel@iogearbox.net>
>> wrote:
>>>
>>> +       if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
>>> +               tcf_destroy_chain(chain);
>>> +               err = 0;
>>> +               goto errout;
>>> +       }
>>
>>
>> We need to notify users we removed which filters, right?
>
>
> As far as I know, most such use cases that listen on this are bypasses
> that mirror kernel configs from user space ... but well, sure, I can add
> a notification if people care. Would do this as a separate patch.

This is fundamental for libnl to update caches.

I don't understand why it should be separated, since notification is
not a feature, we already have notifications in other paths.

>
> Looking into this, I would probably make this a single notification that
> denotes this 'wild-card' removal for that parent instead of calling
> tfilter_notify() for each filter separately (which allocs skb, dumps it,
> etc), qdisc del doesn't loop through it either, so probably fine this way.

Makes sense.

Thanks.
