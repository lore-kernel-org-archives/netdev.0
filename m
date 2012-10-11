From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 17:59:49 +0100
Message-ID: <CAHkRjk70TNGA29AFq=oogx=UOVsS9dJOr0vLyx-di0STpoUHuQ@mail.gmail.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <506ED18C.3010009@gmail.com>
 <20121005140556.GQ4625@n2100.arm.linux.org.uk> <506EEFBB.3060705@gmail.com>
 <507619FA.6080001@jonmasters.org> <yw1xtxu1pwtv.fsf@unicorn.mansr.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
 <yw1xpq4ppcju.fsf@unicorn.mansr.com> <1349949638.21172.8445.camel@edumazet-glaptop>
 <1349950926.21172.8521.camel@edumazet-glaptop> <20121011103257.GO4625@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:51634 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757733Ab2JKRAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 13:00:12 -0400
Received: by mail-qa0-f46.google.com with SMTP id c26so5763425qad.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 10:00:11 -0700 (PDT)
In-Reply-To: <20121011103257.GO4625@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 October 2012 11:32, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Thu, Oct 11, 2012 at 12:22:06PM +0200, Eric Dumazet wrote:
>> I took a look, and I dont see why/how gcc could use a ldm instruction
>>
>> Doing so assumed the alignment of the structure was 8 bytes, but its
>> not.
>>
>> Networking stack mandates that IP headers are aligned on 4 bytes
>> boundaries, not 8 bytes.
>
> Err, no.  ldm is "load multiple" not "load double".  It loads multiple
> 32-bit registers, and its requirement for non-faulting behaviour is for
> the pointer to be 4 byte aligned.  However, "load double" requires 8
> byte alignment.

It got better with ARMv6 where LDRD/STRD only require 4 byte alignment
(the only 8 byte alignment is required by LDREXD/STREXD). But on ARMv5
LDRD/STRD 8 byte alignment is indeed required (otherwise
unpredictable).

-- 
Catalin
