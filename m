From: jamal <hadi@cyberus.ca>
Subject: Re: [RFR] gianfar ethernet driver
Date: 08 Jul 2004 21:42:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089337366.1050.179.camel@jzny.localdomain>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com>
	 <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com>
	 <40EB89CC.2040100@pobox.com>
	 <D3458628-D05D-11D8-BA44-000393C30512@freescale.com>
	 <40EDCAC8.2050509@pobox.com>
	 <944A2374-D137-11D8-8835-000393C30512@freescale.com>
	 <1089336744.1048.169.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andy Fleming <AFLEMING@motorola.com>,
        netdev@oss.sgi.com, Kumar Gala <kumar.gala@motorola.com>,
        dwmw2@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <1089336744.1048.169.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-08 at 21:32, jamal wrote:

> There may be some confusion.
> There is overhead with NAPI in the case of low packet rates.
> What "low rate" means is dependent on your cpu capacity. For example
> consider the following:
> - CPU interupted, interupt disabled, rx thread scheduled
> - rx thread picks a packet off the DMA ring and process it to completion
> - receive thread asks for another packet but none has come in since last
> one --> interupts enabled
> .. x ms go by
> - another packet comes in and process repeats.
> 
> In the above case as you can see the CPU can process each packet fast
> enough i.e before next packet comes in. How fast depends on your CPU.

I should have said also how loaded your CPU is. If your CPU is already
loaded with other work it probably wont be processing those packets fast
enough. Try running a while(1); loop program in user space and see.

> The above also shows that there are now at least two extra PCI
> operations (dis/enabling) interupts which wouldnt happen in the non-NAPI
> case. This will show up via slightly increased CPU usage typically.
> Yep, those web bench people bitch about this but so far weve seen no
> reason to change this. At low rates you should have plenty of CPU
> anyways. 
> Thats what i meant earlier that NAPI could be problematic at "low
> rates". Infact as hinted to you already once you exceed that "low rate"
> threshold, the CPU availability goes down.

Meant: CPU becomes more available.

> What you can do is amortize the cost of that interupt enable/disable
> operation by rx coalescing as suggested by Jeff. So now instead of
> getting an immediate interupt for each incoming packet you get it for
> more than one or after a timeout.
> 
> Hopefully this helps.
> 
> cheers,
> jamal
> 
> 
> 
