From: Andy Fleming <afleming@freescale.com>
Subject: Re: Ethernet driver general problem ....
Date: Thu, 9 Jun 2005 16:04:48 -0500
Message-ID: <A4E721FE-2CEB-4DC8-BF9E-6C8EBAA949BB@freescale.com>
References: <20050609205348.GT4661@mea-ext.zmailer.org>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050609205348.GT4661@mea-ext.zmailer.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Look into ethtool.  ethtool allows you to configure the ring sizes,  
among other things.

On Jun 9, 2005, at 15:53, Matti Aarnio wrote:

> I encountered today a case, where default RX_RING_SIZE
> was too small for the traffic going thru.  (3c59x driver,
> and NAT-router application.)
>
> One related problem is, that the RING_SIZE is hard #define
> parameter in most driver sources without ability to adjust
> it during runtime.  (e.g.  "modprobe zzzz rx_ring_size=512")
> Possibly even an  ifconfig:able  parameter, which works
> also for statically compiled kernels.  (But needs new
> ifconfig machinery...)
>
>
> The case at hand was solved by editing kernel sources, and
> compiling a new kernel, but now I am looking for a more
> generic approach.
>
>
> Clearly pre-allocing 500 buffers of 1.6 kB in size does
> eat a bit much of kernel memory which usual workstation
> does not get benefit from, but server or router would get
> benefits.
>
> Having the rx_ring_size  ifconfig  tunable would help with
> adjusting interface for reception, but adding ifconfig
> parameters is ... not trivial.
>
> Alternate might be  sysctl  tunability -- even as a global
> 'dev.eth.rx_ring_size' (or  'net.dev.eth.rx_ring_size')
> which supplies (default) ring size for initialization of
> the interface where such rings exist at all...
>
>
> Possibly there should also be tx_ring_size, which need not
> be same size as the rx_ring_size.
>
> Unadjusted default value for both could be 16.
>
>
> All in all, this needs near uniquitous changes in driver
> init codes accross lots of network drivers.
>
>
> Comments ?  Suggestions ?
>
>   /Matti Aarnio
>
