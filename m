From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [Patch net-next] net: remove some useless list_del()
Date: Wed, 04 Jun 2014 10:26:22 +0200
Message-ID: <538ED82E.7070407@redhat.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com> <1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com> <1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com> <CAADnVQK+JUp63oETwazjkmouyQqn8ph9Ssbe=B6qhChcHgcgrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbaFDI03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 04:26:29 -0400
In-Reply-To: <CAADnVQK+JUp63oETwazjkmouyQqn8ph9Ssbe=B6qhChcHgcgrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2014 04:18 AM, Alexei Starovoitov wrote:
> On Tue, Jun 3, 2014 at 5:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2014-06-03 at 17:11 -0700, Cong Wang wrote:
>>> "list_kill" is allocated on stack and it's a list head,
>>> it is pointless to call list_del(&kill_list) especially
>>> after unregister_netdevice_many().
>>
>> How pointless exactly ? Explain more please.
>>
>> I suggest you read various commits adding these list_del()
>>
>> f87e6f47933e3ebeced9bb12615e830a72cedce4 is a good start.
>
> Interesting thread. Thanks guys!
> detailed explanation by Linus:
> https://lkml.org/lkml/2011/2/17/267

Indeed, thanks for the pointer. On that note, if you grep for
unregister_netdevice_many() invocations, you'll see many more
such cases that would need a list_del() actually.
