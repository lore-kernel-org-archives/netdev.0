From: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
Subject: RE: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 05:34:24 +0000
Message-ID: <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
 <20141015.002514.384962932982389732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20141015.002514.384962932982389732.davem@davemloft.net>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, October 15, 2014 12:25 PM
> To: Pan Jiafei-B37022
> Cc: jkosina@suse.cz; netdev@vger.kernel.org; Li Yang-Leo-R58472; linux-
> doc@vger.kernel.org
> Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
> 
> From: Pan Jiafei <Jiafei.Pan@freescale.com>
> Date: Wed, 15 Oct 2014 11:26:11 +0800
> 
> > In some platform, there are some hardware block provided
> > to manage buffers to improve performance. So in some case,
> > it is expected that the packets received by some generic
> > NIC should be put into such hardware managed buffers
> > directly, so that such buffer can be released by hardware
> > or by driver.
> >
> > This patch provide such general APIs for generic NIC to
> > use hardware block managed buffers without any modification
> > for generic NIC drivers.
> 
> Why are existing interfaces insufficent for your needs?
> 
> Several ethernet drivers already build SKBs from block
> buffer pools.
> 
Yes, for this matter, in order to do this we should modify the Ethernet
drivers. For example, driver A want to driver B, C, D.. to support driver
A's Hardware block access functions, so we have to modify driver B, C, D...
It will be so complex for this matter.

But by using my patch, I just modify a Ethernet device (I don't care
Which driver it is used) flag in driver A in order to implement this
Ethernet device using hardware block access functions provided by
Driver A.

> They allocate pools of pages which the hardware divides into various
> powers of 2, then the RX descriptor says what pieces of which pools
> were used to hold the data for a packet, and then the SKB is
> constructed with page frags pointing to those locations.
> 
> It's very cheap, inexpensive, and existing APIs are considered to
> cover all use cases.
