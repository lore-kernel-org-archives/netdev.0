From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: tg3 driver and interrupt coalescence questions
Date: Wed, 28 Jun 2006 07:04:57 +0200
Message-ID: <7e63f56c0606272204m6e481b8dm20359d2dc4429b3b@mail.gmail.com>
References: <44A167EB.8000805@netgeeks.net> <44A17A13.8090704@hp.com>
	 <44A17F28.6020802@netgeeks.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:21579 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1423145AbWF1FE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 01:04:59 -0400
Received: by nf-out-0910.google.com with SMTP id h2so716964nfe
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 22:04:57 -0700 (PDT)
To: "Chris A. Icide" <chris@netgeeks.net>
In-Reply-To: <44A17F28.6020802@netgeeks.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Cris,

> I'm looking to decrease the interrupt load on the system.  During the
> test I mentioned above I had some interesting and confusing results.
> The changes from the default settings to the settings I posted resulted
> in a 100% performance increase (counted by the number of VoIP audio
> streams the tested server could support).  With default settings one of
> the two CPUs in the system maxed out at 99% cpu usage handling
> interrupts, while the second CPU was not maxed out, but we started to
> drop packets and the VoIP call setups started showing retransmits (which
> is the measurement for failure in this test) at about 300 streams.  With
> the new settings we were able to hit 600 streams.
>
> So I definately recognized a significant improvement.  However I'd still
> like to get more improvement.  At 600 streams and 20ms packets we are
> looking at 30,000 pps.  The % of cpu (1 CPU as apparently the interrupts
> can't be shared across multiple CPUs) used for interrupt handling at
> this 600 stream limit was 88.0%.

interrupts can be balances across multiple CPUs or not.
It depends on 4 areas:
1. enabling/disabling such option in kernel upon compilation;
2. enabling/disabling of a user-space service for interrupt balancing,
"irqbalance" on redhat, nothing such on debian;
3. enabling of disabling cpu affinity for an irq;

Normally, irq-affinity for a nic interrupt is considered good, but if a CPU
is overloaded you may try irq balancing.

> Now what was interesting was on the test generation side (same hardware
> exactly) of things, I was using the SIPP software to generate the VoIP
> streams, and each blade in the blade server was only able to generate
> ~200 streams, with default settings in ethtool, one of the CPUs would
> hit max usage for interrupt handling at that point.  So I modified the
> ethtool settings to match those I listed above and there was no
> discernable difference.  It was identical performance to the default
> settings.

RTP streams generation can burn your CPU cycles as well as output
of them to network, thus balancing of the
load among the CPUs, irqbalancing may improve something.

-- 
Sincerely,
------------------------------------------------------------------
Robert Iakobashvili, coroberti at gmail dot com
Navigare necesse est, vivere non est necesse.
------------------------------------------------------------------
