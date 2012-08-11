From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net-next] af_packet: relax BUG statement in tpacket_destruct_skb
Date: Sat, 11 Aug 2012 09:11:34 +0200
Message-ID: <CAD6jFUSCXV7QdNAgZZNVDJ9FTFAvV0Qx+_Zyte6agnfr9-DdVw@mail.gmail.com>
References: <1344530345.28842.11.camel@thinkbox>
	<20120810.165450.638010040921216276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42914 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab2HKHLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2012 03:11:45 -0400
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1T05rK-0005HK-FT
	for netdev@vger.kernel.org; Sat, 11 Aug 2012 09:11:42 +0200
Received: from [209.85.214.174] (helo=mail-ob0-f174.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1T05tM-0004bI-Ps
	for netdev@vger.kernel.org; Sat, 11 Aug 2012 09:13:48 +0200
Received: by obbuo13 with SMTP id uo13so3432915obb.19
        for <netdev@vger.kernel.org>; Sat, 11 Aug 2012 00:11:34 -0700 (PDT)
In-Reply-To: <20120810.165450.638010040921216276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 11, 2012 at 1:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Borkmann <danborkmann@iogearbox.net>
> Date: Thu, 09 Aug 2012 18:39:05 +0200
>
>> Here's a quote of the comment about the BUG macro from asm-generic/bug.h:
>>
>>  Don't use BUG() or BUG_ON() unless there's really no way out; one
>>  example might be detecting data structure corruption in the middle
>>  of an operation that can't be backed out of.  If the (sub)system
>>  can somehow continue operating, perhaps with reduced functionality,
>>  it's probably not BUG-worthy.
>>
>>  If you're tempted to BUG(), think again:  is completely giving up
>>  really the *only* solution?  There are usually better options, where
>>  users don't need to reboot ASAP and can mostly shut down cleanly.
>>
>> In our case, the status flag of a ring buffer slot is managed from both sides,
>> the kernel space and the user space. This means that even though the kernel
>> side might work as expected, the user space screws up and changes this flag
>> right between the send(2) is triggered when the flag is changed to
>> TP_STATUS_SENDING and a given skb is destructed after some time. Then, this
>> will hit the BUG macro. Instead, we relax this condition with a WARN_ON_ONCE
>> macro, so that the user is aware of this situation. I've tested it and the
>> system still behaves /stable/, so in accordance with the above comment, we
>> should rather relax this behavior with a warning.
>>
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
>
> I would like this check to simply be deleted completely.
>
> As you said, it's a user changable value, therefore we cannot use it
> for kernel side internal consistency checks at all.

Thanks for the feedback, I will resend a proper patch!

Best,
Daniel
