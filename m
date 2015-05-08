From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while
 creating kernel sockets
Date: Fri, 8 May 2015 13:27:32 -0700
Message-ID: <CAHA+R7N4w4B_2GZfNfxinqPAHPqHEQo__TKt3m88fyHzerEj2g@mail.gmail.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
	<87sib76kef.fsf@x220.int.ebiederm.org>
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
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37342 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219AbbEHU1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 16:27:34 -0400
Received: by widdi4 with SMTP id di4so39544043wid.0
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 13:27:33 -0700 (PDT)
In-Reply-To: <87sib76kef.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 10:36 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> It really is invalid for a network namespace init routine to grab the
> reference count of it's network namespace (thus making the network
> namespace unfreeable).  So I am wondering if perhaps all we need to do
> is find a clean refactoring of the socket code so this case does not
> come up at all.


Good point!

I _guess_ the reason is these kernel sockets have to exist longer than
netns' life-time, it could be due to on-flying skb's?

On the other hand, we do create some fb_tunnel netdevice in netns init
too, but we don't take a refcnt there, probably because we wait
for netdevice refcnt goes to zero when unregistering.
