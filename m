From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3: tg3_stop_block timed out
Date: Mon, 4 Sep 2006 11:25:45 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FAF4@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <44FB58C3.2060209@datafoundry.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Bernd Schubert" <bernd-schubert@gmx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:18695 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751417AbWIDSZ6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 14:25:58 -0400
Content-class: urn:content-classes:message
In-Reply-To: <44FB58C3.2060209@datafoundry.com>
To: "Philip Molter" <philip@datafoundry.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philip Molter wrote:

> Is there any additional information that I can give to help get some 
> more work targeted at this bug?  I've been getting this 
> lockup three or 
> four times a week per server (I have four of them exhibiting 
> this behavior).
> 
> The network setup is fairly complicated, but unfortunately, these are 
> production machines pushing multi-gigabit traffic loads.  We're using 
> vlans on top of bonding on top of anywhere from 2-to-6 
> broadcomm NICs, 
> but it appears that the problem is unrelated to the bonding 
> and vlans, 
> as others are reporting similar problems without those enabled.
> 
> Any assistance would be appreciated.  I've left the original 
> information 
> below for reference.

Since you're using a rather old version of tg3, I suggest that you
upgrade to a newer version first.  Your problem is probably
different from Bernd Schubert's since he has ASF enabled and you
don't.

> 
> If anyone could even explain what this error means, that would be 
> helpful.  Maybe we can change something to work around it.
> 

The stop_block error messages are not too important.  The important
thing is that you're getting a transmit timeout.  It means that
the tx queue is getting full because the NIC is no longer getting
interrupts.  When this condition is detected, the NIC will get reset
which should normally bring the NIC back to life.  It seems that
in your case, it doesn't come back.  Do you get these timeouts on
both ports at the same time?

Please try the latest driver.  If you still get the timeouts, I'll
need to send you some debug patches to dump the state when these
timeouts occur.

