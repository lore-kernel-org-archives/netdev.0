From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] ibmtr init section usage
Date: Mon, 8 Mar 2004 09:01:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308090154.721ea21a.rddunlap@osdl.org>
References: <OF771FE017.1DA04DD7-ON85256E51.0050720A-85256E51.00508E13@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike_Phillips@URSCorp.com
In-Reply-To: <OF771FE017.1DA04DD7-ON85256E51.0050720A-85256E51.00508E13@urscorp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 8 Mar 2004 09:39:52 -0500 Mike_Phillips@URSCorp.com wrote:

| 
| >probe functions can be __devinit.
| 
| > Patch is to 2.6.4-rc2.  Please apply.
| 
| Will this blow up the pcmcia ibmtr_cs. It links in ibmtr and uses the probe
| functions.

Should be OK.  See:

#ifdef CONFIG_HOTPLUG
#define __devinit
#define __devinitdata
#define __devexit
#define __devexitdata
#else
#define __devinit __init
#define __devinitdata __initdata
#define __devexit __exit
#define __devexitdata __exitdata
#endif


and PCMCIA/CardBus depends on HOTPLUG being enabled.

--
~Randy
