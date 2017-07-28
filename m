From: Klavs Klavsen <kl@vsen.dk>
Subject: Re: TCP fast retransmit issues
Date: Fri, 28 Jul 2017 08:36:49 +0200
Message-ID: <0d41553d-69ac-651c-9c41-743391619a40@vsen.dk>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
 <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <fd335e0a0c914b9c42a754da2d24b1c3@vsen.dk> <20170726141847.GC1737@1wt.eu>
 <0b60368890bdb9aa1cf1df4bd0bf21cf@vsen.dk> <20170726143827.GD1737@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jaina.enableit.dk ([109.238.49.194]:46232 "EHLO
        kolab01.enableit.idk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751681AbdG1GhU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 02:37:20 -0400
In-Reply-To: <20170726143827.GD1737@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network guys know what caused it.

Appearently on (atleast some) Cisco equipment the feature:

TCP Sequence Number Randomization

is enabled by default.


It would most definetely be beneficial if Linux handled SACK "not 
working" better than it does - but then I might never have found the 
culprit who destroyed SACK :)

Willy Tarreau wrote on 26-07-2017 16:38:
> On Wed, Jul 26, 2017 at 04:25:29PM +0200, Klavs Klavsen wrote:
>> Thank you very much guys for your insight.. its highly appreciated.
>>
>> Next up for me, is waiting till the network guys come back from summer
>> vacation, and convince them to sniff on the devices in between to pinpoint
>> the culprit :)
> That said, Eric, I'm a bit surprized that it completely stalls. Shouldn't
> the sender end up retransmitting unacked segments after seeing a certain
> number of ACKs not making progress ? Or maybe this is disabled when SACKs
> are in use but it seems to me that once invalid SACKs are ignored we should
> ideally fall back to the normal way to deal with losses. Here the server
> ACKed 3903858556 for the first time at 15:59:54.292743 and repeated this
> one 850 times till 16:01:17.296407 but the client kept sending past this
> point probably due to a huge window, so this looks suboptimal to me.
>
> Willy


-- 
Regards,
Klavs Klavsen, GSEC - kl@vsen.dk - http://www.vsen.dk - Tlf. 61281200

"Those who do not understand Unix are condemned to reinvent it, poorly."
   --Henry Spencer
