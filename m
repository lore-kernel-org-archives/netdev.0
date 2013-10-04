From: jason.morgan@aveillant.com
Subject: Re: tx checksum offload in rtl8168evl disabled in driver
Date: Fri, 4 Oct 2013 10:15:54 +0100
Message-ID: <OF48469889.D817DB84-ON80257BFA.0032A86F-80257BFA.0032E20E@aveillant.com>
References: <OF3E5567E2.6AC62D58-ON80257BF9.004ED219-80257BF9.004F713D@aveillant.com> <20131003230120.GA25047@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-240.asp.reflexion.net ([69.84.129.240]:46613 "EHLO
	asp.reflexion.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751149Ab3JDJPV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 05:15:21 -0400
In-Reply-To: <20131003230120.GA25047@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ubuntu 12.04.3 LTS + Kernel 3.8.13-8 64bit

I've patched the driver to allow tx checksum offload for this chip and=20
found the following:

MTU 9000 standard driver:
517Mbps with 2k + header frames

MTU 9000 patched driver:
770Mbps with 2k + header frames

100% transfer without error (1e6 frames)

48% increase in performance combined with a massive decrease in CPU =
effort=20
is not to be sniffed at.

IMO tx offload should be more prevalent as the frames grow, to reduce 
CPU=20
load.

OK, so make the default OFF if there is a silicon error (that spans=20
mulitple chips?) , but why prevent it being turned on in the driver? -=20
even if there is a kernel message that this might cause problems.




From:   Francois Romieu <romieu@fr.zoreil.com>
To:     <jason.morgan@aveillant.com>, 
Cc:     netdev@vger.kernel.org, hayeswang@realtek.com
Date:   04/10/2013 00:01
Subject:        Re: tx checksum offload in rtl8168evl disabled in driver



jason.morgan@aveillant.com <jason.morgan@aveillant.com> :
[...]
> I'm at 517Mbps and I've found that there seems to be a cpu bottleneck.

Which kernel ?

> I'm using 2k to 4k frames with a rtl8168evl.
> I've found this message
> http://www.spinics.net/lists/netdev/msg216530.html
[...]
> However the message thread, above indicates that this is not a problem 
and 
> can be changed to make tx-checksum offload possible.
> 
> However we are using a newer chip to the on in the message thread. I've 
> tried to find other, more recent citations without success.
> 
> So, why is it still turned off ?

It has been disabled since d58d46b5d85139d18eb939aa7279c160bab70484 
("r8169:
jumbo fixes"). Patch was submitted as a RFC on 2011/07/17 and Hayes was
explicitely requested to comment on the jumbo part if necessary. Patch was
submitted for inclusion on 2011/09/22.

Tx checksumming and jumbo are mutually exclusive in Realtek's driver as 
well.

It seems no recent gigabit chipset reliably supports it.

> What will be the effect of turning it on (changing false to true, in the 

> driver line) for our chip ?

YMMV.

Hayes may elaborate.

-- 
Ueimor
