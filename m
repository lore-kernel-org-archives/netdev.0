From: "Pandita, Vikram" <vikram.pandita@ti.com>
Subject: RE: [PATCH] [RFC] Potential bug in defining 'irq field' of 'ifmap
 structure'
Date: Wed, 8 Jul 2009 02:27:51 +0530
Message-ID: <FCCFB4CDC6E5564B9182F639FC35608702F55E9549@dbde02.ent.ti.com>
References: <CD8CC2B65FEE304DA95744A5472698F202952C3124@dlee06.ent.ti.com>
 <20090706.172501.136390568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Sonasath, Moiz" <m-sonasath@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20090706.172501.136390568.davem@davemloft.net>
Content-Language: en-US
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>> dev_ifsioc_locked()
>> 	case SIOCGIFMAP:
>> 			ifr->ifr_map.irq = dev->irq;   // ?? type mismatch
>>
>> Here
>> ifr->ifr_map.irq) is of type unsigned char
>> dev-irq is of type unsigned int
>>
>> So ifconfig reports a wrong irq number when the dev->irq number is > 255.
>
>This is a known and unavoidable limitation of this interface.
>It's only real use is to control ISA style IRQs which are < 255.

On Zoom2 TI OMAP3 based board, the IRQ we are requesting is value=381 and hence the problem reported.
We do understand that this would break all user level code.

>
>> I am confused to see the same typedefs in file: net/if.h
>> Not sure how to make changes for the user side net/if.h file?

Any idea why net/if.h user level file does not have same definitions as linux/if.h?
In other words, what is the origin of net/if.h file?

>>
>> Signed-off-by: Moiz Sonasath <m-sonasath@ti.com>
>> Signed-off-by: Vikram Pandita <vikram.pandita@ti.com>
>
>You can't make these kinds of changes, every userland binary out there
>using this structure would break.

