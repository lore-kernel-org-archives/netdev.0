From: Ricardo Landim <ricardolan@gmail.com>
Subject: Re: UDP splice
Date: Mon, 24 Jun 2013 14:09:19 -0300
Message-ID: <CACYKsS5uy6nGbtCYit0eNyBSemzimgLrVdUJAgeBmZwDAy7F-A@mail.gmail.com>
References: <CACYKsS7pMFNdBxU2raMphKyb1zU7MEbhc=vsD+FdZ5sgFq71NQ@mail.gmail.com>
	<1372088554.1896.3.camel@bwh-desktop.uk.level5networks.com>
	<20130624155154.GD10413@order.stressinduktion.org>
	<1372089776.1896.9.camel@bwh-desktop.uk.level5networks.com>
	<20130624170119.GE10413@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Ben Hutchings <bhutchings@solarflare.com>,
	Ricardo Landim <ricardolan@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:62588 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab3FXRJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 13:09:20 -0400
Received: by mail-oa0-f47.google.com with SMTP id m1so12083654oag.6
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 10:09:20 -0700 (PDT)
In-Reply-To: <20130624170119.GE10413@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Useful for UDP proxy, mainly for RTP payload including voice (voip)
and video live stream...

2013/6/24 Hannes Frederic Sowa <hannes@stressinduktion.org>:
> On Mon, Jun 24, 2013 at 05:02:56PM +0100, Ben Hutchings wrote:
>> On Mon, 2013-06-24 at 17:51 +0200, Hannes Frederic Sowa wrote:
>> > On Mon, Jun 24, 2013 at 04:42:34PM +0100, Ben Hutchings wrote:
>> > > splice() works with streams, but UDP is a message-oriented protocol.
>> > > How would a UDP implementation of splice() decide where to put the
>> > > message boundaries, or to distinguish the messages?
>> >
>> > Splicing a pipe to udp socket should work nontheless. Splicing from udp socket
>> > to pipe does not work.
>>
>> Should it?  I suppose it could work for UDP-based protocols that include
>> their own framing, but I can't see that it's generally useful.
>
> It is the same with sendfile: One splice-call would result in one udp
> message and could span several ip fragments. So, message boundaries
> would be maintained. splice is good for large data but the generation of
> fragments defeat its use here.
>
> I don't know what would be most suitable to use for copying udp fragments
> from one socket to another socket. I would have tried recvmmsg/sendmmsg.
>
> Greetings,
>
>   Hannes
>
