From: "Chris A. Icide" <chris@netgeeks.net>
Subject: Re: tg3 driver and interrupt coalescence questions
Date: Tue, 27 Jun 2006 11:55:36 -0700
Message-ID: <44A17F28.6020802@netgeeks.net>
References: <44A167EB.8000805@netgeeks.net> <44A17A13.8090704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 68-185-24-3.static.mdfd.or.charter.com ([68.185.24.3]:16786
	"EHLO pbx.netgeeks.net") by vger.kernel.org with ESMTP
	id S932526AbWF0S5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 14:57:49 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <44A17A13.8090704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>
> Are you looking to increase or decrease the settings?  I would think
> (initially at least) that for VOIP one might not want to increase them.
>
> rick jones
I'm looking to decrease the interrupt load on the system.  During the
test I mentioned above I had some interesting and confusing results. 
The changes from the default settings to the settings I posted resulted
in a 100% performance increase (counted by the number of VoIP audio
streams the tested server could support).  With default settings one of
the two CPUs in the system maxed out at 99% cpu usage handling
interrupts, while the second CPU was not maxed out, but we started to
drop packets and the VoIP call setups started showing retransmits (which
is the measurement for failure in this test) at about 300 streams.  With
the new settings we were able to hit 600 streams.

So I definately recognized a significant improvement.  However I'd still
like to get more improvement.  At 600 streams and 20ms packets we are
looking at 30,000 pps.  The % of cpu (1 CPU as apparently the interrupts
can't be shared across multiple CPUs) used for interrupt handling at
this 600 stream limit was 88.0%.

Now what was interesting was on the test generation side (same hardware
exactly) of things, I was using the SIPP software to generate the VoIP
streams, and each blade in the blade server was only able to generate
~200 streams, with default settings in ethtool, one of the CPUs would
hit max usage for interrupt handling at that point.  So I modified the
ethtool settings to match those I listed above and there was no
discernable difference.  It was identical performance to the default
settings. 

Michael's response clarified for me what the actual parameters in the -C
section of ethtool do, thanks Michael.  However I';; be greatly
appreciative of any recommedations anyone might have for interrupt
mitigation settings for 100% UDP RTP traffic of 20ms packets (50 pps per
stream).

-Chris

