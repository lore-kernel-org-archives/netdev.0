From: "Injong Rhee" <rhee@ncsu.edu>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Wed, 29 Oct 2008 20:54:04 -0400
Message-ID: <001d01c93a2a$023f2560$6c01a8c0@RHEELAPTOP>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>	<20081029153928.3d47e26f@extreme>	<000b01c93a1c$090222c0$6c01a8c0@RHEELAPTOP> <20081029164045.7422b68d@extreme> <4908F775.9040504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: "Injong Rhee" <rhee@eos.ncsu.edu>, <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:39489 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbYJ3BjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 21:39:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In any situation where delayed acks screw things up, HyStart would work 
exactly like the old slow start. No harm is done. Since those long delayed 
acks are simply filtered out, HyStart would not detect the exit points 
correctly -- in this particular case, it would delay the exit point until 
packet losses occur. Then this is the behavior of the old slow start.

If some bad implementation causes HyStart to exit from slow start too early 
(before the full utilization of the network), then it can be a problem. But 
we have not found that case. Even over asymmetric paths, premature exits do 
not occur (well based on our own def of premature exits, of course).


----- Original Message ----- 
From: "Rick Jones" <rick.jones2@hp.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Cc: "Injong Rhee" <rhee@ncsu.edu>; "Injong Rhee" <rhee@eos.ncsu.edu>; 
<netdev@vger.kernel.org>
Sent: Wednesday, October 29, 2008 7:53 PM
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start


> Stephen Hemminger wrote:
>> On Wed, 29 Oct 2008 19:14:03 -0400
>> "Injong Rhee" <rhee@ncsu.edu> wrote:
>>
>>
>>>>This looks like a good optimization, it obviously needs more testing
>>>>because Linux always seems to find new broken hardware.  The areas
>>>>that need to be tested should include:
>>>> * MacOs has a broken version of delayed ack that might cause
>>>>   HyStart to radically underestimate.
>>>
>>>We tested with FreeBSD. I presume that it covers MacOS. We will look into 
>>>that.
>>
>>
>> No Darwin added some stupid code that holds off acks for up to 2 seconds.
>
> Is this Apple's reimplementation of the ACK avoidance heuristics in OSX 
> they used to have in previous versions of MacOS with the Mentat TCP/IP 
> stack?
>
> FWIW, HP-UX and Solaris also have ACK avoidance heursistics - they have a 
> Mentat history - although both should be pretty good and neither should 
> hold-off ACKs for two seconds...
>
> rick jones
> 

