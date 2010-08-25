From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Thu, 26 Aug 2010 00:59:42 +0200
Message-ID: <20100825225942.GA3190@hell>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
 <1282632262.2378.1681.camel@edumazet-laptop>
 <4C737D15.5060400@nets.rwth-aachen.de>
 <423116d1d215b0fb3d1c966fb8167508@localhost>
 <4C73DE32.1030802@nets.rwth-aachen.de>
 <20100824162844.GA7889@nuttenaction>
 <AANLkTikAGKObYnczsVoKnUOewJBp2J2036yOD7TncA0F@mail.gmail.com>
 <cb32d2a8676d5447e04882302228c4b6@localhost>
 <AANLkTi=B4gtLxfDnJOuXUCoA79bV4c0cgSn+y36N0iRb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:38188 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751972Ab0HYW7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 18:59:44 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=B4gtLxfDnJOuXUCoA79bV4c0cgSn+y36N0iRb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jerry Chu | 2010-08-25 13:20:52 [-0700]:

>Ok, let's try to finalize the API signature so our apps folks can program to it
>now and don't have to change it later when we have a more complete
>implementation involving the TCP option as well.
>
>What should we call this new option? TCP_UTO or TCP_USERTIMEOUT
>or else?

Well, currently I am not sure if this is the best idea. Your implementation
address the local timeout, user's can tweak their local timeout. UTO on the
other hand provides functionality to tweak peer's timeout. I will use your
timeout implementation (see the comments below) if I receive a TCP UTO options
message, but via setsockopt TCP_UTO I try to modify peer's TCP timeout. Local
and remote RTO of them must not necessarily coherent.  For example the local
RTO can be larger as the remote RTO.

My idea is that TCP_UTO should be used for the remote part. Another option
should be taken for the local part, no matter if TCP_UTO will overwrite the
local part too if the local timeout if smaller as the announced timeout.

TCP_REMOTE_UTO and TCP_LOCAL_RTO, ... no idea at the moment! ;(

Any ideas on that?

>It will take a single argument of unsigned int in milliseconds
>(right?) that specifies
>"user_timeout". The first retransmit timer pops after user_timeout will cause
>the connection to be aborted and ETIMEOUT to be returned.

2^32 / (1000 * 60 * 60 * 24) > 22 days -> great!

>>This interface should be sufficient for you and later
>> for me. Afterwards I provide an patch which apply on your groundwork. My
>> patch handle TCP UTO specific functionality like TCP option protocol
>> handling functionality, socket option, permissions, lower- and upper
>> bounds, ...
>
>The keepalive timer is driven off a different timer sk_timer than
>icsk_retransmit_timer
>so as far as code is concerned they are separate (and I don't see any
>interaction
>between the two).
>
>But RFC5482 does contain the following paragraph:
>
>4.2. TCP Keep-Alives
>
>   Some TCP implementations, such as those in BSD systems, use a
>   different abort policy for TCP keep-alives than for user data.  Thus,
>   the TCP keep-alive mechanism might abort a connection that would
>   otherwise have survived the transient period without connectivity.
>   Therefore, if a connection that enables keep-alives is also using the
>   TCP User Timeout Option, then the keep-alive timer MUST be set to a
>   value larger than that of the adopted USER TIMEOUT.
>
>At this moment I'm not inclined to muck with the keepalive code (although
>the change could be simple) so I'll leave this case for you to handle.
>
>>
>> Today in the evening I will focus on TCP Quick ACK modifications. After
>> that I am in the Alps for vacation for 5 days. Later on I will work on the
>> patch (the patch is in a good state, modification and testing should
>> consume only 2 evenings - hopefully ;-).
>>
>> Cherry, is this ok for you?
>
>Sound good (and it's Jerry, not the girlish Cherry :) Oh, please comment on
>my plan above.

Sounds good for me! I mean I must see working code for final conclusion, but
the basic components are good. And sorry for the naming, Jerry - it was not
intention!

Hagen
