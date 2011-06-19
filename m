From: Ben Greear <greearb@candelatech.com>
Subject: Re: Ethernet low-level frame debugging support
Date: Sun, 19 Jun 2011 13:19:44 -0700
Message-ID: <4DFE59E0.9070503@candelatech.com>
References: <20110619104431.23a22fe9@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34677 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab1FSUTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 16:19:54 -0400
In-Reply-To: <20110619104431.23a22fe9@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2011 06:14 PM, Mark Smith wrote:
> Hi,
>
> Firstly, I think this is a potentially quite useful feature for
> networking people and that I hope it makes it into the kernel proper.
>
> One thing I've thought is that perhaps it might be made and named a bit
> more generally, as NICs will also drop frames for other reasons other
> than FCs failures e.g. runt frames. So perhaps something like "true
> promiscuous" or "full promiscuous" might be a more general name, and if
> it is enabled, then all NIC error checking that can be switched off is
> switched off. Looking at the chipset data sheets for a few NICs that I
> have / have had (netgear FA312 (natsemi ns83815), smc epic100, ne2000),
> they all seem to have registers which allow switching off many if not
> all of the NIC error checking settings.

I called it 'save-rxerr' in ethtool...I think that is general enough?

The early patch that saves the FCS just passes the 4-byte FCS up the stack.
It doesn't change the ability to receive bad frames or not..that is in the
later patches.

>
> The other thing I've thought could be useful would be to be able to
> send runts by not padding the frames when they're less then 64 bytes.
> I've been able to test if this is possible with the netgear FA312, as
> the chipset does the padding. I connected it back to back with an
> e1000e I have, switched off the chipset automatic padding on the FA312,
> sent small traffic, and then saw that the e1000e's internal
> rx_short_length_errors counter correspondingly increased. Of course I
> can't see them with tcpdump on the e1000e because it is dropping them.

Maybe the SO_NOFCS option could change to SO_DRVOPTS and take a bit-field
instead of just be on/off.  NOFCS could be one flag, NOPAD another, etc.
That would give ability to send non-padded frames if the driver has
support.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
