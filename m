From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer
	descriptor ownership.
Date: Thu, 03 May 2007 11:00:50 -0500
Message-ID: <463A0732.2060802@freescale.com>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net>
	<F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org>
	<4638F0C4.2000406@freescale.com>
	<FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org>
	<4638F734.2040809@freescale.com>
	<41B347BE-06AA-4346-BEFB-19DFB52AC533@kernel.crashing.org>
	<463902EB.8070401@freescale.com>
	<Pine.LNX.4.64.0705022109350.1690@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <Pine.LNX.4.64.0705022109350.1690@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> So what about some thing like this where we do the read only once?
> 
> - k
> 
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index a06d8d1..9cd7d1e 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -1438,31 +1438,35 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
>  {
>  	struct rxbd8 *bdp;
>  	struct sk_buff *skb;
> -	u16 pkt_len;
> +	u16 pkt_len, status;
> +	u32 bd_info;


I suggested that on IRC yesterday, and Segher was concerned that the 
compiler might, in theory, "optimize" it into to two lhz instructions. 
I'm rather skeptical that it would actually do so (even if it needs to 
load twice due to register pressure, why not just use lwz both times?), 
and there's probably many other places that would break if it did, but I 
wasn't up for digging around GCC to prove otherwise.

Plus, that wouldn't synchronize the bd_info read with the buffer data reads.

-Scott
