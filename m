From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 12:25:39 +0100
Message-ID: <87y4dnfxl8.fsf@stressinduktion.org>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com> <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com> <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com> <20151123.145433.1554000376541433305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, kernel-team@fb.com, davewatson@fb.com,
	alexei.starovoitov@gmail.com
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49238 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751797AbbKXLZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 06:25:41 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 190FF20DC6
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 06:25:41 -0500 (EST)
In-Reply-To: <20151123.145433.1554000376541433305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

David Miller <davem@davemloft.net> writes:

> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 23 Nov 2015 09:33:44 -0800
>
>> The TCP PSH flag is not defined for message delineation (neither is
>> urgent pointer). We can't change that (many people have tried to add
>> message semantics to TCP protocol but have always failed miserably).
>
> Agreed.
>
> My only gripe with kcm right now is a lack of a native sendpage.
> We should be able to zero copy data through KCM streams without
> any problems whatsoever.

I understood from Tom's last mail that the messages are being
constructed *in kernel memory* before sending out of the tcp
socket. What advantage gives sendpage? The message construction must
actually happen before to fill in the necessary headers for the length,
so receiver can dissect again. Streaming semantics don't really fit
here?

Bye,
Hannes
