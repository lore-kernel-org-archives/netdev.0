From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Mon, 06 Jun 2016 21:25:46 +0200
Message-ID: <5755CE3A.7050002@iogearbox.net>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net> <CAM_iQpWDc1JAa9MhcSAOdJVVRoG52Z+p47CD-rd81LzN28zk1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54520 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbcFFTZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 15:25:52 -0400
In-Reply-To: <CAM_iQpWDc1JAa9MhcSAOdJVVRoG52Z+p47CD-rd81LzN28zk1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2016 07:12 PM, Cong Wang wrote:
> On Sat, Jun 4, 2016 at 9:24 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> +       if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
>> +               tcf_destroy_chain(chain);
>> +               err = 0;
>> +               goto errout;
>> +       }
>
> We need to notify users we removed which filters, right?

As far as I know, most such use cases that listen on this are bypasses
that mirror kernel configs from user space ... but well, sure, I can add
a notification if people care. Would do this as a separate patch.

Looking into this, I would probably make this a single notification that
denotes this 'wild-card' removal for that parent instead of calling
tfilter_notify() for each filter separately (which allocs skb, dumps it,
etc), qdisc del doesn't loop through it either, so probably fine this way.

Thanks,
Daniel
