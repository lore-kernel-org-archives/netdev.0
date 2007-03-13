From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Tue, 13 Mar 2007 16:53:54 +0300
Message-ID: <45F6ACF2.2050300@ru.mvista.com>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com> <20070311121615.GF8133@sirena.org.uk> <45F5502C.1000905@ru.mvista.com> <20070312191120.GA3085@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:5171 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S965735AbXCMNyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 09:54:07 -0400
In-Reply-To: <20070312191120.GA3085@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Mark Brown wrote:

>>>Moving netdev_rx() would fix that one but there's some others too -
>>>there's one in the timer routine if the chip crashes.  In the case you

>>   Erm, sorry, I'm not seeing it -- could you "point with finger" please? 
>>   :-)

> In netdev_timer() when the device is using PORT_TP if the DspCfg read
> back from the chip differs from the one we think we programmed into it
> then the driver thinks the PHY fell over.  It then goes through an init
> sequence, including init_registers() which will reset IntrEnable among
> other things.

    What's more important for us, it will also clear IntrStatus (and ignore 
all pending interrupts).  Well, as it will also reinit the whole TX/RX rings, 
so that all packets will be lost...

>>>describe above the consequences shouldn't be too bad since it tends to
>>>only occur at high volume so further traffic will tend to occur and
>>>cause things to recover - all the testing of that patch was done with
>>>the bug present and no ill effects.

>>   Oversized packets occur only at high volume? Is it some errata?

> It's an errata - AN 1287 which you can get from the National web site.
> It's not actually that chip that's getting oversided packets, what
> happens is that the state machine which reads data off the wire gets
> confused and eventually locks up.  Before locking up it will usually
> report one or more oversided packets so this is a useful hint that we
> should reset the recieve state machine in order to recover from this.

    That's all good by why we need to completely lose TX and other interrupts
in the meantime? High inbound traffic doesn't necessarily mean a high outbound 
one, does it?

WBR, Sergei

