From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Wed, 22 Dec 2004 16:02:44 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>,
        "Peter Chubb" <peterc@gelato.unsw.edu.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Because callers are not supposed to depend upon the value 
> being set to anything valid if tg3_readphy() returns an error.
> 
> I thought it should never be returning an error at this spot. 
>  The PHY should always return a valid value within 
> PHY_BUSY_LOOPS.  If MI_COM_BUSY is staying set for such a 
> long time that's a pretty serious problem.
> 
> Taking a peek at the bcm5700 driver by Broadcom, they handle 
> all PHY read timeouts the way your patch does in this one 
> spot, by setting the returned value to zero.  So it seems the 
> device can time out like that in these situations, and your 
> patch is something close to the correct fix.
> 
> Good catch Peter, I'll think some more about this and 
> probably end up using something similar to your second patch.
> 
> Thanks.
> 

David, While the 2nd patch or something similar should be applied, I
think the underlying cause of tg3_readphy() returning error should be
further investigated.

Peter, if you provide more information, such as registers MAC_MI_MODE
(0x454) and MAC_MI_COM (0x44c) after the failure, I can look into it.

Michael
