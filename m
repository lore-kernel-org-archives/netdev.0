From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: ALTPATCH: 8139cp: LinkChg support
Date: Fri, 20 Sep 2002 09:21:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D8B20CD.80403@mandrakesoft.com>
References: <1032487254.247.7.camel@tank> 	<3D8ABCEF.9060207@mandrakesoft.com> <1032494983.247.70.camel@tank>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe W Damasio <felipewd@terra.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Felipe W Damasio wrote:
>>+	int advertise, lpa, media, duplex;
> 
> 
> 	Shouldn't advertise and lpa be either "unsigned short" or u16?

No, they don't need to be.



>>+	lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
>>+
>>+	/* figure out media and duplex from advertise and LPA values */
>>+	media = mii_nway_result(lpa & advertise);
> 
>         ^^^^^^^^^^^^^^^^^^^^^^^ 
> 
> 	mii_nway_result returns a "unsigned int", so media also doesn't look
> good.

mii_nway_result _really_ returns a small bitmapped value, so it doesn't 
matter.


>>+	duplex = (media & (ADVERTISE_100FULL | ADVERTISE_10FULL)) ? 1 : 0;
> 
> 
> 	Or we could do
> 
> 	duplex = (media & ADVERTISE_FULL) ? 1 : 0;


True.  I forgot about that constant...

	Jeff
