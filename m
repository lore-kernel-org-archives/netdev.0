From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: RE: [PATCH 2/6] net: Add a struct net parameter to sock_create_kern
Date: Tue, 12 May 2015 10:58:19 -0500
Message-ID: <006C93D3-B9F6-44C9-8D1E-DA95E38BD0A6@xmission.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com> <87wq0kcqlm.fsf@x220.int.ebiederm.org> <20150508140733.GA13325@gondor.apana.org.au> <87sib76kef.fsf@x220.int.ebiederm.org> <20150509011339.GA19116@gondor.apana.org.au> <87383633pu.fsf_-_@x220.int.ebiederm.org> <87oalu1p16.fsf_-_@x220.int.ebiederm.org> <063D6719AE5E284EB5DD2968C1650D6D1CB33641@AcuExch.aculab.com> <110296A8-1CC9-456C-B126-50C90D4E3E17@xmission.com> <063D6719AE5E284EB5DD2968C1650D6D1CB33707@AcuExch.aculab.com> <5551F205.1080707@6wind.com> <063D6719AE5E284EB5DD2968C1650D6D1CB338CF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
	"'nicolas.dichtel@6wind.com'" <nicolas.dichtel@6wind.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55060 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbbELP6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:58:31 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB338CF@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On May 12, 2015 8:16:23 AM CDT, David Laight <David.Laight@ACULAB.COM> =
wrote:
>From: Nicolas Dichtel [mailto:nicolas.dichtel@6wind.com]
>> Sent: 12 May 2015 13:29
>> Le 12/05/2015 13:48, David Laight a =C3=A9crit :
>> > From: Eric W. Biederman
>> >> Sent: 12 May 2015 09:55
>> >>
>> >> On May 12, 2015 3:24:11 AM CDT, David Laight
><David.Laight@ACULAB.COM> wrote:
>> > ...
>> >>> Wouldn't it involve far less churn to add a new function that
>uses a
>> >>> non-default namespace?
>> >>
>> >> The goal is comprehensible and maintainable kernel code.
>> >>
>> >> Which network namespace your socket is in, is an important
>property and something you probably care
>> >> about if you are creating kernel sockets.
>> >
>> > That rather depends on whether you've anywhere to get a namespace
>from.
>> > eg something like ceph/messenger.c
>> sk_net(con->sock->sk)?
>
>What if you don't already have a socket?
>Just an IP(v6) address ?
>
>> This parameter is essential, hiding it will just hides bugs.
>> Having this parameter forces the developer to ask himself what is th=
e
>best
>> value.
>
>What if the answer is 'NFI'?
>Which requires the answer be pushed back to the 'application'
>configuration?
>Most users will have no idea either.

current->nsproxy->netns.

Capture it at mount time.  Call get_net then and put_net after you have=
 cleaned up during unmount.

Not hard, and the parameter is doing what it is supposed to be doing ge=
tting you to ask the question, and realize there is an unhandled issue.

Eric
