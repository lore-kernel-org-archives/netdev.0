From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next v2] ipv4: inet_bind: check the addr_len first
Date: Tue, 02 Jun 2015 23:30:18 +0200
Message-ID: <1433280618.2482044.285146025.2A214C41@webmail.messagingengine.com>
References: <1433247664-7151-1-git-send-email-kda@linux-powerpc.org>
 <1433255612.1164050.284752905.33D64748@webmail.messagingengine.com>
 <CAOJe8K3_Z91o2H9pWFCtSYMoQSbq2Ga0dYFR1Y=MFYGHsGccuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:52118 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751280AbbFBVaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:30:18 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 482A8203AA
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 17:30:18 -0400 (EDT)
In-Reply-To: <CAOJe8K3_Z91o2H9pWFCtSYMoQSbq2Ga0dYFR1Y=MFYGHsGccuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Jun 2, 2015, at 17:13, Denis Kirjanov wrote:
> On 6/2/15, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > Hello,
> >
> > On Tue, Jun 2, 2015, at 14:21, Denis Kirjanov wrote:
> >> Perform the address length check first, before calling
> >> the proto specific bind() function
> >
> > Can you give more detail why you did this change and what bug it fixes?
> I've sent the v2 version with the net-next tag. The idea is simple:
> check the error condition first and then do the useful work.

Hmm, IMHO the specific proto->bind handlers have to take care of the
check themselves. You could argue that we should do the checks always in
inet_bind but then you have to remove the addr_len checks from the raw
and ping bind handlers, otherwise people become confused if they modify
the code. I am in favor of leaving the current logic as is, sorry.

Thanks,
Hannes
