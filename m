From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Thu, 10 Mar 2005 18:27:48 -0500
Message-ID: <4230D7F4.8060900@pobox.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>	 <1110334456.32556.21.camel@gaston>	 <20050308194229.41c23707.davem@davemloft.net>	 <1110340214.32524.32.camel@gaston>	 <57a429f8eb807987d88b06129861d507@freescale.com>	 <4230D1AC.5070506@katalix.com> <1110495992.32525.290.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>,
        Andy Fleming <afleming@freescale.com>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>, linuxppc-embedded@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1110495992.32525.290.camel@gaston>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> On Thu, 2005-03-10 at 23:01 +0000, James Chapman wrote:
> 
>>Hi Andy,
>>
>>Can you elaborate on why this phy abstraction is needed?
>>
>>In your original post, you mentioned that you were going to post a
>>patch to show how your code would be hooked up in an existing net
>>driver. Did I miss it? It would help in understanding the pros and cons
>>of using genphy over using plain old mii.c.
>>
>>btw, I recently posted a patch to add GigE support to mii.c which is
>>in Jeff's netdev-2.6 queue. Some register definitions were added in
>>mii.h that will collide with yours.
> 
> 
> A variety of PHY chips require special cases that aren't handled by the
> generic mii code. The PHY driver layer allows to plug PHY specific
> drivers, with genphy just being the "default" for sane chips.
> 
> Also, I think Andy added more to the PHY layer than what mii does, like
> support for the interrupt or timer based link management etc... which
> tend to be the same in a lot of drivers.

Nod.

I haven't had time to review the phy abstraction layer, but my gut 
feeling is that there are several common code patterns which could be 
abstracted out, to save code.

Typically there will be one or more phy-specific functions in each 
10/100 or GigE driver, falling back to a default 'genphy' driver when 
things are completely MII/GMII-compatible.

	Jeff
