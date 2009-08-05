From: Michal Soltys <soltys@ziu.info>
Subject: Re: r8169 (+others ?) and note_interrupt performance hit on 2.6.30.x
Date: Wed, 05 Aug 2009 20:54:47 +0200
Message-ID: <4A79D577.30305@ziu.info>
References: <4A6BA3CE.9000607@ziu.info> <20090726091803.GA28374@electric-eye.fr.zoreil.com> <4A6CA3EF.7080909@ziu.info> <4A6E21B4.7090103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:1207 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177AbZHESyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 14:54:35 -0400
In-Reply-To: <4A6E21B4.7090103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Michal Soltys wrote, On 07/26/2009 08:43 PM:
> 
> ...
>> Anwyay, not sure if this is useful, so if there is anything better
>> I could do, just push me in the right direction.
> 
> Short test of 2.6.29? (Unless you prefer a bisection...)
> 
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

I did first bisection, and the whole cpu load increases seem a bit more 
complicated than I originally thought.

I noticed at least 2 (possibly 3) moments where it increased (from 
original full 1 gbit at 20% - 50% load of one core)

(1) jump from 20% - 50% to 80% - 90%

(2) commit f11a377b3f4e897d11f0e8d1fc688667e2f19708
     r8169: avoid losing MSI interrupts

After the above commit, one core is not enough to handle 1 gbit speed 
with 1k packets, it ends with with ~760mbit and one core drained at 100% 
. The situation right before this commit is as in (1)

All tests were done, as mentioned earlier - with nc process and eth 
interrupts pinned to the same core, and besides nc process - idle 
machine. Tested with udp only, standard pfifo_fast.

The changes happened between 2.6.29 and 2.6.30-rc6 .

I'll try to pinpoint when (1) happens now. Lookint at mpstat output, 
those may actually be two different commits.

