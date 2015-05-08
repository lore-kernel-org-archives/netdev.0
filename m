From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while
 creating kernel sockets
Date: Fri, 8 May 2015 14:13:27 -0700
Message-ID: <CAHA+R7NOrqhOv=ki22Dd8BTdaswp_Mvkz75XkahQSfh73c6a1w@mail.gmail.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
	<CAHA+R7N4w4B_2GZfNfxinqPAHPqHEQo__TKt3m88fyHzerEj2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ying Xue <ying.xue@windriver.com>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, maxk@qti.qualcomm.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>,
	James Chapman <jchapman@katalix.com>,
	Erik Hugne <erik.hugne@ericsson.com>, jon.maloy@ericsson.com,
	Simon Horman <horms@verge.net.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:33823 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981AbbEHVN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 17:13:28 -0400
Received: by wgic8 with SMTP id c8so56609644wgi.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 14:13:27 -0700 (PDT)
In-Reply-To: <CAHA+R7N4w4B_2GZfNfxinqPAHPqHEQo__TKt3m88fyHzerEj2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 1:27 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Fri, May 8, 2015 at 10:36 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> It really is invalid for a network namespace init routine to grab the
>> reference count of it's network namespace (thus making the network
>> namespace unfreeable).  So I am wondering if perhaps all we need to do
>> is find a clean refactoring of the socket code so this case does not
>> come up at all.
>
>
> Good point!
>
> I _guess_ the reason is these kernel sockets have to exist longer than
> netns' life-time, it could be due to on-flying skb's?
>
> On the other hand, we do create some fb_tunnel netdevice in netns init
> too, but we don't take a refcnt there, probably because we wait
> for netdevice refcnt goes to zero when unregistering.

Answer myself, it looks like we don't need to hold the refcnt at all,
since we create the socket at init and release it at uninit, so they
should have the same life-time?

The reason why user-space sockets need this refcnt is they
could have longer life-time than the netns?

This seems the right direction to solve this problem for me,
I am going to try this way to see how far I can go. ;)

Thanks.
