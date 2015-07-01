From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we have
 a TCP_TIMEWAIT sk
Date: Wed, 1 Jul 2015 23:49:25 +0200
Message-ID: <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
	<20150701.141402.587634025761326092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: agartrell@fb.com, netdev <netdev@vger.kernel.org>,
	kernel-team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36430 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbbGAVt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 17:49:27 -0400
Received: by widjy10 with SMTP id jy10so69087139wid.1
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 14:49:25 -0700 (PDT)
In-Reply-To: <20150701.141402.587634025761326092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 1, 2015 at 11:14 PM, David Miller <davem@davemloft.net> wrote:
> From: Alex Gartrell <agartrell@fb.com>
> Date: Wed, 1 Jul 2015 13:13:09 -0700
>
>> If we early-demux bind a TCP_TIMEWAIT socket to an skb and then orphan it
>> (as we need to do in the ipvs forwarding case), sock_wfree and sock_rfree
>> are going to reach into the inet_timewait_sock and mess with fields that
>> don't exist.
>>
>> Signed-off-by: Alex Gartrell <agartrell@fb.com>
>
> If we're forwarding, we should not find a local socket, period.
>
> We should only match sockets for locally destined packets.
>
> So I'd say that the state in which you say this can occur is illegal.

Right, this patch is totally buggy.

A socket cannot change state to TCP_TIMEWAIT.

A new object is allocated and old one is removed from ehash, then
freed (rcu rules being applied)

Also sock_wfree() has nothing to do with early demux. It is for output
path skbs only.
