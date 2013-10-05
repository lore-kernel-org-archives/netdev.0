From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: tx checksum offload in rtl8168evl disabled in driver
Date: Sat, 5 Oct 2013 11:22:52 +0200
Message-ID: <20131005092252.GA23084@electric-eye.fr.zoreil.com>
References: <OF3E5567E2.6AC62D58-ON80257BF9.004ED219-80257BF9.004F713D@aveillant.com>
 <20131003230120.GA25047@electric-eye.fr.zoreil.com>
 <OF48469889.D817DB84-ON80257BFA.0032A86F-80257BFA.0032E20E@aveillant.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: jason.morgan@aveillant.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33018 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408Ab3JEJXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 05:23:02 -0400
Content-Disposition: inline
In-Reply-To: <OF48469889.D817DB84-ON80257BFA.0032A86F-80257BFA.0032E20E@aveillant.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please don't top post)

jason.morgan@aveillant.com <jason.morgan@aveillant.com> :
> Ubuntu 12.04.3 LTS + Kernel 3.8.13-8 64bit
> 
> I've patched the driver to allow tx checksum offload for this chip and
> found the following:
>
> MTU 9000 standard driver:
> 517Mbps with 2k + header frames
> 
> MTU 9000 patched driver:
> 770Mbps with 2k + header frames
> 
> 100% transfer without error (1e6 frames)

(Ok, so that's 20 ~ 30s worth of traffic)

> 48% increase in performance combined with a massive decrease in CPU
> effort is not to be sniffed at.

*sniff* :o)

It depends on the CPU. You did not specify it and you did not give numbers
for the decrease (did you use 'perf' btw ?). They would be welcome.

> IMO tx offload should be more prevalent as the frames grow, to reduce 
> CPU load.

I can't disagree.

> OK, so make the default OFF if there is a silicon error (that spans
> mulitple chips?),

Yes, I want safe defaults for the kernel.

I give the manufacturer's explanations a lot of credit when they're
related to hardware (up to the point where the marketing or legal dept
kicks in). If we want to balance these with experimental evidences, the
latter must be really, really strong.

> but why prevent it being turned on in the driver? 
> even if there is a kernel message that this might cause problems.

Two points:
- it's a hack: ethtool will return success. A kernel message is not a
  substitute for "Yes, I opt in for problems".
- we can't tell when it's safe and when it isn't.

-- 
Ueimor
