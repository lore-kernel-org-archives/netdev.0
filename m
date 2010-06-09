From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Wed, 9 Jun 2010 17:15:42 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006091713260.30265@obet.zrqbmnf.qr>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com> <4C08EB85.3050900@trash.net> <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com> <4C0FA24A.7060907@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:42701 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734Ab0FIPPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 11:15:44 -0400
In-Reply-To: <4C0FA24A.7060907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2010-06-09 16:16, Patrick McHardy wrote:
>>>> I'd like to be able to sendout a single IP packet with MF flag set.
>>>>
>>>> When using RAW sockets the packet will get stuck in the
>>>> netfilter (NF_INET_LOCAL_OUT nf_defrag_ipv4 reassembly unit)
>>>> and wont ever make it out..
>>>>
>>>> I made a change which bypass the outgoing reassembly for
>>>> RAW sockets, but I'm not sure wether it's too invasive..
>>>>       
>>> That would break reassembly (and thus connection tracking) for cases
>>> where its really intended.
>>>     
>>>> Is there any standard for RAW sockets behaviour?
>>>> Or another way around? :)
>>>>       
>>> You could use the NOTRACK target to bypass connection tracking.
>>
>> I tried the NOTRACK target, but the packet is still going
>> throught reassembly, because the RAW filter has lower priority
>> then the connection track defragmentation..
>
>Right.

Blech. That reminds me of
http://marc.info/?l=netfilter-devel&m=126581823826735&w=2
