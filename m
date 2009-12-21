From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Mon, 21 Dec 2009 13:28:34 -0800
Message-ID: <4B2FE882.3080207@redfish-solutions.com>
References: <4B298118.2000608@redfish-solutions.com> <200912171724.32711.schmto@hrz.tu-chemnitz.de> <4B2A8A5C.9070702@redfish-solutions.com> <200912212150.34727.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:32845 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751701AbZLUV2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 16:28:40 -0500
In-Reply-To: <200912212150.34727.schmto@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2009 12:50 PM, Torsten Schmidt wrote:
> Hi Philip,
> 
> here a second PATCH to add the missing DSCP classes to 
> ipv4_dscp_stat(), also tested against 2.6.32. 
> 
> Next step is to add IN / OUT statistic to DSCP. Maybe 
> /proc/net/ipdscp will look like:
> CS0	in	out
> CS1	in	out
> ...
> EF	in	out
> 
> 
> any comments ?
> Torsten

Hi Torsten,

Yes, the MIB changes are certainly important... we are more focused though on actually updating the default queuing strategies.

I'll poke around and see if I can figure out how that works...

Looking at include/linux/pkt_sched.h:

#define TC_PRIO_BESTEFFORT              0
#define TC_PRIO_FILLER                  1
#define TC_PRIO_BULK                    2
#define TC_PRIO_INTERACTIVE_BULK        4
#define TC_PRIO_INTERACTIVE             6
#define TC_PRIO_CONTROL                 7

it seems that these TC priorities are just random, unrelated buckets and their ordinality has no relation to their priority.  Is that correct?

If that's the case, then you *can't* just do:

static inline char rt_dscp2priority(u8 tos)
{
	return IPTOS_PREC(tos)>>5;
}

for instance.  No, that would be too easy.  :-)

-Philip


