From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/3] [RFC] TCP syncookies: slow down timer to mitigate
 spoofing attacks
Date: Thu, 15 Aug 2013 20:34:09 -0400
Message-ID: <CADVnQykQLHBgDLwMd63b5dwnFUbikeQ_-Jp9mjDTNQObS0Z7=Q@mail.gmail.com>
References: <520A3B4A.1050704@jakoblell.com>
	<20130815235743.GA25665@midget.suse.cz>
	<20130816000043.GA11950@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jakob Lell <jakob@jakoblell.com>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:64781 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811Ab3HPAeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 20:34:11 -0400
Received: by mail-ea0-f179.google.com with SMTP id b10so675687eae.24
        for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 17:34:10 -0700 (PDT)
In-Reply-To: <20130816000043.GA11950@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 15, 2013 at 8:00 PM, Jiri Bohac <jbohac@suse.cz> wrote:
> (compile-tested only)
>
> Jakob Lell discovered that the sequence number that needs to be guessed to
> successfully spoof a TCP connection with syncookies only has 27 bits of
> entropy. Of the 32 bits, 2 bits are wasted by the four differrent timestamps
> accepted and 3 are wasted by the 8 differrent RSS values. [1]
>
> This patch slows down the timer used in syncookies from 1/60 Hz to 1/60/4 Hz
> so that at any moment only two differrent timer values can be accepted.
> As a result, 1 bit of sequence number entropy is gained.
>
> This changes the maximum cookie age limit from 4 - 5 minutes to 4 - 8 minutes.
>
> [1]: http://www.jakoblell.com/blog/2013/08/13/quick-blind-tcp-connection-spoofing-with-syn-cookies/
>
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
...

>  /*
> - * This (misnamed) value is the age of syncookie which is permitted.
> + * This value is the age (in seconds) of syncookies which will always be

I believe (hope?) you mean minutes here, rather than seconds. :-) Same
typo occurs in 2 spots each for IPv4 and IPv6.

neal
