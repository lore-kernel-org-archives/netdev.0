From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Thu, 27 Nov 2008 07:14:06 +0100
Message-ID: <492E3AAE.3000709@hartkopp.net>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:49034 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbYK0GP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 01:15:58 -0500
In-Reply-To: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Patrick,

Patrick Ohly wrote:
> This patch series was discussed before on linux-netdev ("hardware
> time stamping + igb example implementation").
(..)

> This patch now adds a 8 byte field unconditionally.

This looks really better to me :-)

> There's one unsolved problem, though: time synchronization with
> PTP (the use case I'm working on) requires a transformation of
> raw hardware time stamps into system time. Currently this is done
> at the socket level by finding the device which created the time
> stamp and letting it do the transformation. This fails for
> incoming packets because skb->rt points to the "lo" device.
>
> Perhaps the interface number can be used to find the real
> hardware device. Alternatively the conversion could be done when
> generating the time stamp (might also be more accurate), but then
> another 8 byte field is needed. Delta encoding won't help because
> one cannot assume that hardware time stamps track system time
> closely enough.
>   

I still have two questions of understanding regarding these (offset) 
transformations that make it still difficult:

1. As no one has an insight of how the specific hardware generates the 
hw time stamp anyway, why can't you put the already transformed values 
into the hw timestamp field? I won't stick on the fact that the hw time 
stamp is the value that has been read from specific controller registers 
that are very hardware depended.

2. From what i've read in the discussion, i understood that the hardware 
clock and the system clock skew. Assuming both to be strong 
monotonic(?), is there a linear skew observable from your testing 
experiences?

If so i would suggest to have some kind of sysfs entry like e.g.

/sys/class/net/eth0/hwstamp_skew_ns

that gives something like

-86234765@12277656012584334095

as output. In general:

<skew_in_ns>@<systemtime>

So if you would check this sysfs entry two or more times, you would get 
an impression about the hw time stamp behaviour of your hardware by 
simply calculating the linear (timedepended) offset based on several 
'skew-sample-points', right?

I hope these suggestions are not completely damaged ;-)

Best regards,
Oliver

