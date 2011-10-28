From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 15:40:24 -0700
Message-ID: <4EAB2F58.7080509@hp.com>
References: <1319836443-4419-1-git-send-email-dbaluta@ixiacom.com> <20111028.171904.1635229691857703124.davem@davemloft.net> <CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com> <20111028.183107.2091450715774357523.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dbaluta@ixiacom.com, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, luto@amacapital.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:11252 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab1J1Wk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 18:40:28 -0400
In-Reply-To: <20111028.183107.2091450715774357523.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2011 03:31 PM, David Miller wrote:
> From: Daniel Baluta<dbaluta@ixiacom.com>
> Date: Sat, 29 Oct 2011 00:35:24 +0300
>
>> On Sat, Oct 29, 2011 at 12:19 AM, David Miller<davem@davemloft.net>  wrote:
>>> From: Daniel Baluta<dbaluta@ixiacom.com>
>>> Date: Sat, 29 Oct 2011 00:14:03 +0300
>>>
>>>> +static inline int tcp_delack_thresh(const struct sock *sk)
>>>> +{
>>>> +     return inet_csk(sk)->icsk_ack.rcv_mss * sysctl_tcp_delack_segs;
>>>> +}
>>>> +
>>>
>>> Please turn this into a shift or something, you're adding a multiply
>>> into a core code path.
>>
>> Is there any generic API to do this? Default case is not
>> affected since tcp_delack_segs is 1.
>
> I'm saying make the tunable a shift count instead of something to
> multiply against.

That would be loads faster, but won't that have issues with granularity? 
  It will allow 1, 2, 4, 8, 16, 32, etc segments but none of the umpteen 
values in between.  FWIW, HP-UX defaults to 22 segments, which IIRC has 
its basis in how many "typical" segments could fit in a 32KB window.

If the mss and the delack segs are being converted into an octet count, 
and multiplication or successive addition etc are too expensive, how 
about using an octet count directly?

rick jones
