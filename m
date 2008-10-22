From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: IP-less bridge as a martian source
Date: Wed, 22 Oct 2008 19:22:20 +0200
Message-ID: <48FF614C.7020507@gmail.com>
References: <87tzb6nodj.fsf@tac.ki.iif.hu> <87wsg0wu78.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:53025 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbYJVRVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 13:21:54 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1430798ugf.37
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 10:21:52 -0700 (PDT)
In-Reply-To: <87wsg0wu78.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ferenc Wagner wrote, On 10/22/2008 05:00 PM:

> Ferenc Wagner <wferi@niif.hu> writes:
> 
>> I expected an IP-less bridge interface to pick up no IP packets, but
>> apparently this isn't the case: broadcast packets with destination
>> address 255.255.255.255 are reported as martians by the 2.6.18
>> kernel, which I find counterintuitive (I know 2.6.18 is rather old,
>> but that's the one supported by Xen).
>>
>>   1. Is this the expected behaviour?


I think so, and this thread pertains to something similar:
http://marc.info/?l=linux-netdev&m=122456602708727&w=2

>>
>>   2. I tried to cut down the logs by explicit iptables drops, but
>>      didn't succeed.  Does martian detection happen before the
>>      netfilter rules?  (I know I can disable martian logging by
>>      interface, but wanted finer granularity.)


It's after netfilter's PREROUTING. (BTW, it's also after ingress
qdisc where you can try some filtering.)

Jarek P.
