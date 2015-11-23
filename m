From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/6] net: Add MSG_BATCH flag
Date: Mon, 23 Nov 2015 11:02:21 +0100
Message-ID: <1448272941.3985012.447402329.73885F37@webmail.messagingengine.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
 <1448054520-1464587-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, davewatson@fb.com, alexei.starovoitov@gmail.com
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41277 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753036AbbKWKCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 05:02:22 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id B6F8420A31
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 05:02:21 -0500 (EST)
In-Reply-To: <1448054520-1464587-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, Nov 20, 2015, at 22:21, Tom Herbert wrote:
> Add a new msg flag called MSG_BATCH. This flag is used in sendmsg to
> indicate that more messages will follow (i.e. a batch of messages is
> being sent). This is similar to MSG_MORE except that the following
> messages are not merged into one packet, they are sent individually.
> 
> MSG_BATCH is a performance optimization in cases where a socket
> implementation can benefit by transmitting packets in a batch.
> 
> This patch also updates sendmmsg so that each contained message except
> for the last one is marked as MSG_BATCH.

This flag is only used for KCM because it does not make sense to expose
it to user space? As such, could this be made more clear? I don't see
such an optimization being needed for UDP or TCP.

Thanks,
Hannes
