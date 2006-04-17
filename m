From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Tue, 18 Apr 2006 01:13:35 +0200
Message-ID: <4444211F.3030000@trash.net>
References: <20060417093632.GA29057@2ka.mipt.ru> <4443B5A8.9010604@trash.net> <20060417194904.GA5237@2ka.mipt.ru> <4443F742.9020508@trash.net> <20060417202150.GA10764@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:8672 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1751372AbWDQXQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 19:16:16 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060417202150.GA10764@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Mon, Apr 17, 2006 at 10:14:58PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> 
>>Not exactly, its not related to the group number. groups used in bind()
>>are considered as bitmask and groups used for setsockopt are considered
>>as group numbers. We can't change bind() because this behaviour is
>>required for compatibility.
> 
> 
> So bind and subscribing are almost exclusive and should not be used
> simultaneously?


No. You have to use bind() if you want to use a socket for sending.
bind() will overwrite the lower 32 groups with whatever is specified
in struct nladdr, if you have used setsockopt(NETLINK_ADD_MEMBERSHIP)
before the call to bind() for a group <= 32 you have to specify the
same group mask or it will get changed. Usually you would call bind()
first if you intend to use the socket for sending and subscribe
to multicast groups afterwards.

>>>But this introduce some problem with subscribing - if one subscribes to
>>>group 5 and is bound to the same group it allows to broadcast not only
>>>to group 5, and those which have the same bits set, but also to group 16
>>>(1<<(5-1)), which has nothing in common with the requested group number.
>>
>>Only if you use group numbers for bind(), which is plainly wrong.
> 
> 
> Even if one uses group bitmask at bind time and later subscribes to
> some group from that bitmask, this will introduce wrong behaviour with
> unrelated gropus.
> Maybe we should not allow to subscribe if group bitmask different from 1
> was used at bind() time?


I went over your mails again, but I don't understand the problem you're
seeing. Please just make a simple example showing the operation +
the arguments you're using to bind to group 5 which would result in
bit 0 beeing set or the kernel deciding to send to group 1 for some
other reason.
