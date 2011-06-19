From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Ethernet low-level frame debugging support
Date: Sun, 19 Jun 2011 10:44:31 +0930
Message-ID: <20110619104431.23a22fe9@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:53180 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393Ab1FSFoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 01:44:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Firstly, I think this is a potentially quite useful feature for
networking people and that I hope it makes it into the kernel proper.

One thing I've thought is that perhaps it might be made and named a bit
more generally, as NICs will also drop frames for other reasons other
than FCs failures e.g. runt frames. So perhaps something like "true
promiscuous" or "full promiscuous" might be a more general name, and if
it is enabled, then all NIC error checking that can be switched off is
switched off. Looking at the chipset data sheets for a few NICs that I
have / have had (netgear FA312 (natsemi ns83815), smc epic100, ne2000),
they all seem to have registers which allow switching off many if not
all of the NIC error checking settings.

The other thing I've thought could be useful would be to be able to
send runts by not padding the frames when they're less then 64 bytes.
I've been able to test if this is possible with the netgear FA312, as
the chipset does the padding. I connected it back to back with an
e1000e I have, switched off the chipset automatic padding on the FA312,
sent small traffic, and then saw that the e1000e's internal
rx_short_length_errors counter correspondingly increased. Of course I
can't see them with tcpdump on the e1000e because it is dropping them. 

Regards,
Mark.
