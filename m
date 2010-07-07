From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: QoS weirdness : HTB accuracy
Date: Wed, 7 Jul 2010 11:40:22 +0000 (UTC)
Message-ID: <loom.20100707T130832-691@post.gmane.org>
References: <067c83163988908ef546d7ff7f560a17@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:47487 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754939Ab0GGMpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jul 2010 08:45:08 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OWTzs-0003Y2-DJ
	for netdev@vger.kernel.org; Wed, 07 Jul 2010 14:45:04 +0200
Received: from nat-dhcp.lanfw.cxnet.dk ([87.72.215.200])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 14:45:04 +0200
Received: from hawk by nat-dhcp.lanfw.cxnet.dk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 14:45:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julien Vehent <julien <at> linuxwall.info> writes:

> I observe unused bandwidth on my QoS policy that I cannot explain.
> Conditions are: I have a HTB tree with 8 classes and a total rate of
> 768kbits. I use the ATM option so I assume the real rate to be something
> close to 675kbits (about 88% of the ethernet rate).
> 
> The sum of my 8 rates is exactly 768kbits. Some have ceil values up to
> 768kbits.
> 
> When class 20 "tcp_acks" starts borrowing, TC reduces the total bandwidth
> down to 595kbits/S (minus 79kbits/s). And I can't explain why....

Fortunately, I can explain why.  This is actually the expected/correct
behavior.  The "tcp_acks" class only receives small packets, and small
packets have a significantly higher overhead than larger packets.

The simple explanation is that small packets will (almost) always
result in two ATM frames being transmittet, thus resulting in 106
bytes (2x 53 bytes) being used on the link.

 
> The attached graph "tc_htb_weirdness.png" shows the result: there are
> 'holes' in the sending rate. 

This is as explained above the behavior I expected to see.  As the
small packets eats/consumes more bandwidth on the physical link, and
your observations are based upon what happens on the Ethernet layer.

-- 
Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


