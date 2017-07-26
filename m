From: Klavs Klavsen <kl@vsen.dk>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 16:25:29 +0200
Message-ID: <0b60368890bdb9aa1cf1df4bd0bf21cf@vsen.dk>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
 <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <fd335e0a0c914b9c42a754da2d24b1c3@vsen.dk> <20170726141847.GC1737@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jaina.enableit.dk ([109.238.49.194]:46998 "EHLO
        kolab01.enableit.idk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751591AbdGZOZo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 10:25:44 -0400
In-Reply-To: <20170726141847.GC1737@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you very much guys for your insight.. its highly appreciated.

Next up for me, is waiting till the network guys come back from summer 
vacation, and convince them to sniff on the devices in between to 
pinpoint the culprit :)

Willy Tarreau skrev den 2017-07-26 16:18:
> On Wed, Jul 26, 2017 at 04:08:19PM +0200, Klavs Klavsen wrote:
>> Grabbed on both ends.
>> 
>> http://blog.klavsen.info/fast-retransmit-problem-junos-linux (updated 
>> to new
>> dump - from client scp'ing)
>> http://blog.klavsen.info/fast-retransmit-problem-junos-linux-receiving-side
>> (receiving host)
> 
> So bingo, Eric guessed right, the client's sequence numbers are 
> translated
> on their way to/from the server, but the SACK fields are not :
> 
> Server :
> 15:59:54.292867 IP (tos 0x8, ttl 64, id 15878, offset 0, flags [DF],
> proto TCP (6), length 64)
>     192.168.32.44.22 > 62.242.222.50.35002: Flags [.], cksum 0xfe2b
> (incorrect -> 0xce0e), seq 1568063538, ack 3903858556,
>     win 10965, options [nop,nop,TS val 529899820 ecr
> 774272020,nop,nop,sack 1 {3903859904:3903861252}], length 0
> 
> Client :
> 15:59:54.297388 IP (tos 0x8, ttl 56, id 15878, offset 0, flags [DF],
> proto TCP (6), length 64)
>     192.168.32.44.22 > 62.242.222.50.35002: Flags [.], cksum 0xbb2c
> (correct), seq 1568063538, ack 2684453645,
>     win 10965, options [nop,nop,TS val 529899820 ecr
> 774272020,nop,nop,sack 1 {3903859904:3903861252}], length 0
> 
> To there's very likely a broken firewall in the middle that is waiting 
> for
> a bug fix, or to have its feature disabled. Sometimes it can also 
> happen
> on firewalls performing some SYN proxying except that it would mangle 
> the
> server's sequence numbers instead of the client ones.
> 
> Willy

-- 
Regards,
Klavs Klavsen, GSEC - kl@vsen.dk - http://blog.klavsen.info - Tlf. 
61281200

"Those who do not understand Unix are condemned to reinvent it, poorly."
   --Henry Spencer
