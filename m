From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Sun, 07 Nov 2010 11:28:08 +0100
Message-ID: <4CD67F38.1060506@hartkopp.net>
References: <1289074307.3090.100.camel@Dan>	<AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com> <20101106.165703.193714684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, drosenberg@vsecurity.com,
	chas@cmf.nrl.navy.mil, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:8908 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab0KGK2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 05:28:50 -0500
In-Reply-To: <20101106.165703.193714684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.11.2010 00:57, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sat, 6 Nov 2010 13:50:32 -0700
> 
>> On Saturday, November 6, 2010, Dan Rosenberg <drosenberg@vsecurity.com> wrote:
>>>
>>> Clearly, in most cases we cannot just remove the field from the /proc
>>> output, as this would break a number of userspace programs that rely on
>>> consistency.  However, I propose that we replace the address with a "0"
>>> rather than leaking this information.
>>
>> I really think it would be much better to use the unidentified number
>> or similar.
>>
>> Just replacing with zeroes is annoying, and has the potential of
>> losing actual information.
> 
> I would really like to see the specific examples of where this is
> happening, it sounds like something very silly to me.

Indeed Urs and me had a similar discussion before we decided to put different
(user relevant) content into the procfs output and break the current layout:

http://patchwork.ozlabs.org/patch/70282/

The layout break was ok in this case as the people using the CAN procfs stuff
do this only when facing problems (with their applications) at runtime.

A discussed approach that won't break the procfs layout was to set the values
to "0" and only fill them with real content depending on CONFIG_DEBUG_INFO .

Would that fit here?

Or maybe a different config option CONFIG_DEBUG_KERNEL_ADDR would do the job,
as i don't know which distros enable CONFIG_DEBUG_INFO by default ...

Regards,
Oliver

