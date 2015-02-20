From: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Subject: Re: [PATCH] Allow specifying bridge port STP state by name rather
 than number.
Date: Fri, 20 Feb 2015 09:40:53 -0500
Message-ID: <CAPFHKze570L6_ODzoEg7qi5r0nbc4XCD5gtz76VHnOieWRrCrw@mail.gmail.com>
References: <20150219192726.GA17950@alexpilon.ca> <CAPFHKzcOFQCtz0pwLm8XOZxTOkC9w4CFq2vcLnwxUfVVmWdNCw@mail.gmail.com>
 <20150220045730.GA7936@alexpilon.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Alex Pilon <alp@alexpilon.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:33419 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035AbbBTOlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:41:24 -0500
Received: by wevk48 with SMTP id k48so6027622wev.0
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 06:41:23 -0800 (PST)
In-Reply-To: <20150220045730.GA7936@alexpilon.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I only looked at your patch, and not the surrounding code. In that
case, I would probably stick with the existing style.

I'm just a casual passer-by, but I would like to hear others' opinion on this,
as I find exit(-1) to always be incorrect. The problem is that, per the man
page:

> The exit() function causes normal process termination and the value
> of status & 0377 is returned to the parent (see wait(2)).

So when -1 is passed to exit(), the parent will see it as 255. Why not
return a value that could be found in the source by grepping for it?

On Thu, Feb 19, 2015 at 11:57 PM, Alex Pilon <alp@alexpilon.ca> wrote:
> On Thu, Feb 19, 2015 at 09:00:23PM -0500, Jonathon Reinhart wrote:
>> Please don't pass -1 to exit().  It is outside the acceptable range (0 to 255)
>> of exit status values:
>>
>> https://www.gnu.org/software/libc/manual/html_node/Exit-Status.html
>>
>> Most programs exit(1) when presented with invalid user input.
>
> I was being consistent with nearby code, and the dominant style.  But if
> that's the case, then there's a few hundred such mistakes that need
> correcting.  Should I fix all of them, and if so, should that be a
> single patch, or multiple?
>
> There's also only a few instances of EXIT_{SUCCESS,FAILURE}, so I took
> it wasn't the style to use that.
>
> Regards,
>
> Alex Pilon



-- 
Computers are incredibly fast, accurate and stupid. Human beings are
incredibly slow, inaccurate and brilliant. Together they are powerful
beyond imagination.
                                    A. Einstein
