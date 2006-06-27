From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 26 Jun 2006 23:50:44 -0400
Message-ID: <44A0AB14.1010605@garzik.org>
References: <20060626212547.GE30706@tuxdriver.com> <44A09289.4040200@garzik.org> <44A097AA.6080809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32217 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030626AbWF0Dur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 23:50:47 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44A097AA.6080809@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger wrote:
> Jeff Garzik wrote:
>> John W. Linville wrote:
>>> +    assert(bcm->mac_suspended >= 0);
>>> +    if (bcm->mac_suspended == 0) {
>>> +        bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
>>> +        bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
>>> +                        bcm43xx_read32(bcm, 
>>> BCM43xx_MMIO_STATUS_BITFIELD)
>>> +                & ~BCM43xx_SBF_MAC_ENABLED);
>>> +        bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy 
>>> read */
>>> +        for (i = 100000; i; i--) {
>>> +            tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
>>> +            if (tmp & BCM43xx_IRQ_READY)
>>> +                goto out;
>>> +            udelay(10);
>>> +        }
>>> +        printkl(KERN_ERR PFX "MAC suspend failed\n");
>>>      }
>>
>>
>> NAK this super-long delay...  should be done in a workqueue, looks like?
>>
>> ACK everything else.
>>
> 
> That delay was set to try to accommodate my interface when it refused to 
> suspend the MAC, which resulted in transmit errors. That problem has 
> since been cured by reworking the periodic work handlers - thus such a 
> long delay should not be needed. The original spec from the clean-room 
> group was a delay loop of 1000. I'm currently testing that value now. If 
> it passes the test, would a for (i=1000; i; i--) be acceptable?

That's acceptable, yes, but it sounds like the problem has since been cured?

	Jeff



