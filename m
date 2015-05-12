From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH 2/6] net: Add a struct net parameter to sock_create_kern
Date: Tue, 12 May 2015 16:15:08 +0200
Message-ID: <55520AEC.4090500@6wind.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com> <87wq0kcqlm.fsf@x220.int.ebiederm.org> <20150508140733.GA13325@gondor.apana.org.au> <87sib76kef.fsf@x220.int.ebiederm.org> <20150509011339.GA19116@gondor.apana.org.au> <87383633pu.fsf_-_@x220.int.ebiederm.org> <87oalu1p16.fsf_-_@x220.int.ebiederm.org> <063D6719AE5E284EB5DD2968C1650D6D1CB33641@AcuExch.aculab.com> <110296A8-1CC9-456C-B126-50C90D4E3E17@xmission.com> <063D6719AE5E284EB5DD2968C1650D6D1CB33707@AcuExch.aculab.com> <5551F205.1080707@6wind.com> <063D6719AE5E284EB5DD2968C1650D6D1CB338CF@AcuExch.aculab.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ying Xue <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"cwang@twopensource.com" <cwang@twopensource.com>,
	"xemul@openvz.org" <xemul@openvz.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"maxk@qti.qualcomm.com" <maxk@qti.qualcomm.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"tom@herbertland.com" <tom@herbertland.com>,
	"jchapman@katalix.com" <jchapman@katalix.com>,
	"erik.hugne@ericsson.com" <erik.hugne@ericsson.com>,
	"jon.maloy@ericsson.com" <jon.maloy@ericsson.com>,
	"horms@verge.net.au" <horms@verge.net.au>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Laight <David.Laight@ACULAB.COM>,
	"'Eric W. Biederman'" <ebiederm@xmission.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35543 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933179AbbELOPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 10:15:11 -0400
Received: by wgnd10 with SMTP id d10so9171470wgn.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 07:15:10 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB338CF@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/05/2015 15:16, David Laight a =C3=A9crit :
> From: Nicolas Dichtel [mailto:nicolas.dichtel@6wind.com]
>> Sent: 12 May 2015 13:29
>> Le 12/05/2015 13:48, David Laight a =C3=A9crit :
>>> From: Eric W. Biederman
>>>> Sent: 12 May 2015 09:55
>>>>
>>>> On May 12, 2015 3:24:11 AM CDT, David Laight <David.Laight@ACULAB.=
COM> wrote:
>>> ...
>>>>> Wouldn't it involve far less churn to add a new function that use=
s a
>>>>> non-default namespace?
>>>>
>>>> The goal is comprehensible and maintainable kernel code.
>>>>
>>>> Which network namespace your socket is in, is an important propert=
y and something you probably care
>>>> about if you are creating kernel sockets.
>>>
>>> That rather depends on whether you've anywhere to get a namespace f=
rom.
>>> eg something like ceph/messenger.c
>> sk_net(con->sock->sk)?
>
> What if you don't already have a socket?
> Just an IP(v6) address ?
So you have an IPv6 address and you don't know on which netns this addr=
ess
belongs? I can't imagine how it can work.

>
>> This parameter is essential, hiding it will just hides bugs.
>> Having this parameter forces the developer to ask himself what is th=
e best
>> value.
>
> What if the answer is 'NFI'?
> Which requires the answer be pushed back to the 'application' configu=
ration?
Your application is bound to a netns.

> Most users will have no idea either.
If you support netns, you *have to know*.


Regards,
Nicolas
