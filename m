From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of
 timestamps?
Date: Tue, 04 Mar 2014 11:33:02 -0800
Message-ID: <53162A6E.2010907@hp.com>
References: <53151E55.9000503@hp.com> <CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com> <53162093.1040208@hp.com> <CABrhC0k5-x=qJgH4izXtRR=9+cLJh_emAy9Yt=+xrY6K5982Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:22331 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbaCDTdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 14:33:05 -0500
In-Reply-To: <CABrhC0k5-x=qJgH4izXtRR=9+cLJh_emAy9Yt=+xrY6K5982Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> There is some other strangeness just before that, where the SACK
>>> block shrinks then grows again.
>>
>>
>> That would be this yes?
>>
>> 15:20:46.798816 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>> 3660468:3661928, ack 4262, win 297, length 1460
>> 15:20:46.799027 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>> 3168256, win 32081, options [nop,nop,sack 1 {3171368:3172828}], length 0
>> 15:20:46.799042 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>> 3661928:3664848, ack 4262, win 297, length 2920
>> 15:20:46.799465 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3172828}], length 0
>> 15:20:46.799479 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>> 3664848:3666308, ack 4262, win 297, length 1460
>> 15:20:46.799497 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3174288}], length 0
>> 15:20:46.799504 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>> 3169716, win 32241, options [nop,nop,sack 1 {3171368:3175748}], length 0
>> 15:20:46.799509 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>> 3666308:3667768, ack 4262, win 297, length 1460
>> 15:20:46.799773 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>> 3171176, win 32491, options [nop,nop,sack 1 {3171368:3172828}], length 0
>> 15:20:46.799787 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>> 3667768:3669228, ack 4262, win 297, length 1460
>> 15:20:46.800063 IP 75.236.145.7.443 > 91.216.86.7.56064: Flags [.], ack
>> 3171368, win 32716, options [nop,nop,sack 1 {3171368:3177208}], length 0
>> 15:20:46.800081 IP 91.216.86.7.56064 > 75.236.145.7.443: Flags [.], seq
>> 3171368:3172828, ack 4262, win 297, length 1460
>>
>> Might that be packet-reordering in the other direction?  Sadly, I don't have
>> good "both sides" traces as the receiving system doesn't seem to capture
>> traffic terribly well.  I suppose TCP timestamps might have helped answer
>> that question.
>
> Regardless of any possible reordering, in this case we know something
> odd is going on in the receiver because ACK advances at the same time
> the SACK block shrinks.

Ah yes, I'd not picked-up on that.

thanks,

rick jones
