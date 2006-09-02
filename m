From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP send/ack lockstep problem
Date: Fri, 01 Sep 2006 23:15:25 -0700
Message-ID: <44F9217D.8030305@osdl.org>
References: <eda9s9$bgq$1@sea.gmane.org> <E1GJLWk-0006P6-00@gondolin.me.apana.org.au> <20060902055317.GA5567@kiste.smurf.noris.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63723 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750810AbWIBGPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2006 02:15:48 -0400
To: Matthias Urlichs <smurf@smurf.noris.de>
In-Reply-To: <20060902055317.GA5567@kiste.smurf.noris.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthias Urlichs wrote:
> Hi,
>
> Herbert Xu:
>   
>> Matthias Urlichs <matthias@urlichs.de> wrote:
>>     
>>> Any ideas? Is the sending program doing something stupid? If so, what?
>>>       
>> Probably.  Since you're on the sender's side (192.109.x.x I presume) why
>> don't you do a strace on the sending process and tell us?
>>
>>     
> The stuff I see in there doesn't look stupid to me.
>
> accept(...) = 216
> setsockopt(216, SOL_IP, IP_TOS, [8], 4) = 0
> setsockopt(216, SOL_TCP, TCP_NODELAY, [1], 4) = 0
> setsockopt(216, SOL_SOCKET, SO_KEEPALIVE, [1], 4) = 0
> followed by a bunch of "interactive" read() and write() calls, and then
> a rather long sequence of 16384-byte writes (all of which end up being
> partial because the send buffer size is 12k).
>
> so if one of these is the cause for the observed lockstep behavior when
> the send buffer is *full*, I'd consider that to be a bug.
>
> Interestingly, the *sender* advertizes window that's (a bit more than) one MTU:
>
> 07:47:03.204939 IP (tos 0x38, ttl  64, id 41217, offset 0, flags [DF], proto: TCP (6), length: 1468) 192.109.102.42.3306 > 62.193.238.120.53138: . 167089:168505 (1416) ack 0 win 1424 <nop,nop,timestamp 218027038 834794727>
>
> but that's the other direction -- is something in the kernel confused about
> which window variable to use ??
>
>   
You could try turning off window scaling:
    sysctl -w net.ipv4.tcp_window_scaling=0
If that fixes it, you have a corrupting middlebox in the path or bad 
implementation on the other end.

Also try turning off tcp_abc (on the sender).
    sysctl -w net.ipv4.tcp_abc=0



-- 
VGER BF report: H 0.050318
