From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] net: smsc: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 09:56:07 +0100
Message-ID: <20130913085607.GA20681@mudshark.cambridge.arm.com>
References: <1379046467-6900-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	davidb@quicinc.com
To: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1379046467-6900-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[adding David Brown]

On Fri, Sep 13, 2013 at 05:27:47AM +0100, Michael Opdenacker wrote:
> This patch proposes to remove the IRQF_DISABLED flag from
> code in drivers/net/ethernet/smsc/
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
> ---
>  drivers/net/ethernet/smsc/smc91x.h   | 2 +-
>  drivers/net/ethernet/smsc/smsc9420.c | 3 +--
>  2 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
> index 370e13d..5730fe2 100644
> --- a/drivers/net/ethernet/smsc/smc91x.h
> +++ b/drivers/net/ethernet/smsc/smc91x.h
> @@ -271,7 +271,7 @@ static inline void mcf_outsw(void *a, unsigned char *p, int l)
>  #define SMC_insw(a, r, p, l)	mcf_insw(a + r, p, l)
>  #define SMC_outsw(a, r, p, l)	mcf_outsw(a + r, p, l)
>  
> -#define SMC_IRQ_FLAGS		(IRQF_DISABLED)
> +#define SMC_IRQ_FLAGS		0

After this change, the only machine that defines the flags to anything other
than IRQF_TRIGGER_RISING is MSM, which uses IRQF_TRIGGER_HIGH. David: do
you actually need this? The irq_chip code under mach-msm doesn't seem to
distinguish between the two.

Will
