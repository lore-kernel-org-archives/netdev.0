From: Jeff Garzik <jgarzik@pobox.com>
Subject: Phy layer notes (was Re: [RFR] gianfar ethernet driver)
Date: Fri, 09 Jul 2004 12:47:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EECC0C.9040304@pobox.com>
References: <8F52CF1D-C916-11D8-BB6A-000393DBC2E8@freescale.com>	 <40E98FB8.4070900@pobox.com> <1089375760.28614.1365.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
        Kumar Gala <kumar.gala@freescale.com>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
In-Reply-To: <1089375760.28614.1365.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> Hmmm. 
> 
> eth0: Running with NAPI disabled
> eth0: 64/64 RX/TX BD ring size
> eth1: Gianfar Ethernet Controller Version 1.0, 05:e6:9e:c0:05:e6
> eth1: Running with NAPI disabled
> eth1: 64/64 RX/TX BD ring size      
> eth0: PHY id 2060e1 is not supported!
> eth0: No PHY found
> IP-Config: Failed to open eth0
> IP-Config: Device `eth0' not found
> 
> The PHY is a BCM5421S. Does it really have to give up completely? Isn't
> there a subset of common MII support it could use?
> 
> Is it expected that every NIC driver will include its own version of
> support for the PHYs which have actually been seen paired with that NIC,
> or is there some more generic support planned?


David W and I discussed some of this on IRC.

1) most gige phys can be treated with generic GMII code.  unfortunately 
experience shows that phy init can often involve phy-specific magic 
sequences.

2) we do need a generic phy layer, and I'm looking for volunteers who 
want to prototype a nice, small, compact one.  BenH has a nice template 
in sungem_phy.c.

3) drivers/net/mii.c and include/linux/mii.h need GMII code and 
constants.  Feel free to add.

4) generic TBI code would be nice, too.  (TBI is a standard gige fibre 
interface)

5) sometimes a MAC+phy pairing is unique enough that you need 
MAC-specific support for a particular phy.  For example, one might wind 
up with two phy drivers, one a generic Broadcom GMII phy driver (for use 
by any NIC driver), and one a tg3-specific Broadcom GMII phy driver.
