From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] packet: clean up error variable assignments
Date: Tue, 23 Oct 2012 19:25:19 +0200
Message-ID: <CAD6jFUQeaMD3RMBN2AKLfQwc=uvZSY3wd=B58-6+im7CrUnB3Q@mail.gmail.com>
References: <20121023115629.GA8664@thinkbox>
	<1351011952.8609.2334.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45156 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757250Ab2JWRZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:25:27 -0400
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TQiEI-0002sN-8h
	for netdev@vger.kernel.org; Tue, 23 Oct 2012 19:25:26 +0200
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLSv1:RC4-SHA:128)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TQiEL-0002tW-CX
	for netdev@vger.kernel.org; Tue, 23 Oct 2012 19:25:29 +0200
Received: by mail-ea0-f174.google.com with SMTP id c13so1243879eaa.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:25:19 -0700 (PDT)
In-Reply-To: <1351011952.8609.2334.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 23, 2012 at 7:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-10-23 at 13:56 +0200, Daniel Borkmann wrote:
>> This patch performs clean-ups of packet's err variables where appropriate.
>> In particular, errnos are *only* assigned in error cases, which saves
>> useless instructions in non-error cases and makes the code more readable
>> in terms of which error type belongs to which evaluated error condition.
>> Also, in some cases an errno was set, but not used until the next assignment.
>
> I see no value in this patch.
>
> Setting err before a test is a common way to handle error cases and
> generates smaller code in linux kernel.
>
> Better live with it than trying to change it ?
>
> err = -ENOMEM;
> match = kzalloc(xxxx);
> if (!match)
>         goto error;
>
>
> is smaller (source code & generated code) than :
>
> match = kzalloc(xxxx);
> if (!match) {
>         err = -ENOMEM;
>         goto error;
> }
>
> An immediate load is basically free, but code size matters.

Good to know, thanks for the feedback Eric!
