From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 2 Jan 2012 17:40:54 +0100
Message-ID: <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com> <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:55642 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab2ABQlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 11:41:17 -0500
Received: by werm1 with SMTP id m1so7486455wer.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 08:41:16 -0800 (PST)
In-Reply-To: <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I don't really know what it can do, but it has to do encoding (even if
>> it is a SoC, with dedicated devices, memory has to be used).
>> The main problem I have, is that I don't have the two boards with me
>> today, and even if I can prototype on x86, I can't conclude as far as
>> I don't test on the real HW.
>
> Thats going to be tough. You could at least use one board and test if it
> can send 100Mbits using netperf (on a x86 target), and check cpu usage.

Mmmh, using netperf you would like to know what the client (my ARM
board) can do ?
How would you test it ? I can have an ARM board on one side, and the
x86 on the other...

>> This is also why I want to prototype my best bet in the first try :).
>> And this is mainly a networking/memory problem.
>
> If the 'no packet loss happens in the network' requirement is OK, then a
> plain sendfile() [ or splice() ] will work.
>
> Limiting each tcp frame to a 1 or 2 lines of your image is about
> limiting MSS on your tcp session (setsockopt( ... TCP_MAXSEG ))

Yes, the idea of limiting tcp frame to 2 lines is to avoid
fragmenting. So, with a MTU at 1500, MSS=1460, I can put 2 lines <=
730bytes. I will probably have ~700bytes.

JM
