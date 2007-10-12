From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 18:29:51 -0700
Message-ID: <470ECE0F.4060506@candelatech.com>
References: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com><20071011.163737.36654032.davem@davemloft.net><470EB6D6.9020704@hp.com> <20071011.170244.32082446.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC32903C440EE@orsmsx414.amr.corp.intel.com> <470EBD2C.8020704@candelatech.com> <470ECC71.1070303@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:47501 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628AbXJLBaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 21:30:06 -0400
In-Reply-To: <470ECC71.1070303@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> Ben Greear wrote:
>> I just tried turning off my explicit SO_SNDBUF/SO_RCVBUG settings in 
>> my app,
>> and the connection ran very poorly through a link with even a small
>> bit of latency (~2-4ms I believe).
> 
> I often run at full gigabit or faster with latencies of 100+ ms.  Can 
> you give a bit more detail?

I'm doing non-blocking TCP sends, write sizes of around 64k, and I'm
doing this to/from the same system with the send-to-self patch.
I am running full-duplex (930+Mbps tx + rx on both ports)
(this is about 980Mbps on the wire).

If I don't set the tx-queue % rx-queue sizes large (~4MB), it does not
perform well when running through my latency emulator.

If I do set them, then it runs just fine (barring an occassional
TCP throughput deadlock & ACK storm that is being worked on separately.)

If it works for other people, then it could be something else
weird about my setup.  I have an easy work-around (been in the
code for years and years now), so I'm not too worried either way.

Thanks,
Ben

> 
>   -John


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

