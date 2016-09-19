From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH next] sctp: make use of WORD_TRUNC macro
Date: Mon, 19 Sep 2016 00:05:54 -0300
Message-ID: <b14bab91-cd8b-221b-a3de-75c97bba67f7@gmail.com>
References: <b40b1bd4adff2d389588d9a4710af0399ce68d1e.1473963064.git.marcelo.leitner@gmail.com>
 <20160918.220629.1190601768509139321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36742 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937573AbcISDG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 23:06:58 -0400
In-Reply-To: <20160918.220629.1190601768509139321.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 18-09-2016 23:06, David Miller escreveu:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Thu, 15 Sep 2016 15:12:30 -0300
>
>> No functional change. Just to avoid the usage of '&~3'.
>> Also break the line to make it easier to read.
>
> You're reply later in this thread:
>
> 	"to make sure it is correctly adapted to some arch if
> 	necessary. (even though it's not necessary in this case)"
>
> is inconsistent with your commit log message.
>
> If you think that the word size might possibly be different
> on a given arch, then this is in fact a functional change.
>

Alright, that was badly worded, sorry. I meant not about the macro in 
specific but in a more general way, as in to not use magic hardcoded 
values, just that.

> This patch just adds ambiguity.  Whereas the existing code is explicit
> about "multiple of 4" and there can be no confusion.
>

On the other hand, it brings the code closer to a standard. This is the 
one but last occurrence of '~3' throughout sctp code. There is only one 
other spot left. All of them are using WORD_ROUND or WORD_TRUNC macros 
already.

We can rename the macros, I agree they sound confusing. Proposing 
SCTP_ALIGN4 and SCTP_TRUNC4. Does that sound better? Then I'll send a 
patchset renaming and updating all remaining places.

> I'm not applying this, sorry.
>
