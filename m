From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] packet: clean up error variable assignments
Date: Wed, 24 Oct 2012 09:47:01 +0200
Message-ID: <CAD6jFUSAkXjFK1tjEAw8tG1YueatRF-kCyjpv61N-3TD-fMtvg@mail.gmail.com>
References: <20121023115629.GA8664@thinkbox>
	<1351011952.8609.2334.camel@edumazet-glaptop>
	<1351033824.5283.80.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47249 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934441Ab2JXHrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 03:47:09 -0400
Received: from [78.46.5.204] (helo=sslproxy02.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TQvgC-00084R-2F
	for netdev@vger.kernel.org; Wed, 24 Oct 2012 09:47:08 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy02.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TQvg8-00078B-Vs
	for netdev@vger.kernel.org; Wed, 24 Oct 2012 09:47:05 +0200
Received: by mail-ee0-f46.google.com with SMTP id b15so63220eek.19
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2012 00:47:01 -0700 (PDT)
In-Reply-To: <1351033824.5283.80.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 24, 2012 at 1:10 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2012-10-23 at 19:05 +0200, Eric Dumazet wrote:
>> On Tue, 2012-10-23 at 13:56 +0200, Daniel Borkmann wrote:
>> > This patch performs clean-ups of packet's err variables where appropriate.
>> > In particular, errnos are *only* assigned in error cases, which saves
>> > useless instructions in non-error cases and makes the code more readable
>> > in terms of which error type belongs to which evaluated error condition.
>> > Also, in some cases an errno was set, but not used until the next assignment.
>>
>> I see no value in this patch.
>>
>> Setting err before a test is a common way to handle error cases and
>> generates smaller code in linux kernel.
>>
>> Better live with it than trying to change it ?
>>
>> err = -ENOMEM;
>> match = kzalloc(xxxx);
>> if (!match)
>>       goto error;
>>
>>
>> is smaller (source code & generated code) than :
>>
>> match = kzalloc(xxxx);
>> if (!match) {
>>       err = -ENOMEM;
>>       goto error;
>> }
>>
>> An immediate load is basically free, but code size matters.
>
> In my experience gcc is generally able to perform this optimisation
> itself, at least for x86.  Setting 'err' only after checking for failure
> seems clearer, but I think this is really a matter of taste.

It might also be more likely in case code gets removed, that the
relating 'err' will be removed as well. If I remember correctly, I've
seen one or two cases where there was an assignment with no 'return'
in between the next assignment of 'err'. But probably spatch could
detect such cases as well.
