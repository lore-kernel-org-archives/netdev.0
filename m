From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH 2/2] ravb: add sleep PM suspend/resume support
Date: Wed, 10 Aug 2016 12:58:10 +0200
Message-ID: <20160810105810.GB14397@bigcity.dyn.berto.se>
References: <20160803135647.23242-1-niklas.soderlund+renesas@ragnatech.se>
 <20160803135647.23242-3-niklas.soderlund+renesas@ragnatech.se>
 <20c30e52-0b7b-0f8f-9001-0d05da628572@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	davem@davemloft.net, wsa@the-dreams.de
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20c30e52-0b7b-0f8f-9001-0d05da628572@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-08-10 13:40:51 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 8/3/2016 4:56 PM, Niklas Söderlund wrote:
> 
> > The interface would not function after the system had been woken up
> > after have been suspended (echo mem > /sys/power/state) cycle. The
> > reason for this is that all device registers have been reset to its
> > default values. This patch adds sleep suspend and resume functions that
> > detached the interface at suspend and restore the registers and reattach
> > the interface at resume.
> > 
> > Only the registers that are only configured at probe time needs to be
> > explicitly restored by the resume handler. All other registers are
> > reconfigured by either reopening the device in the resume handler (if
> > the device was running when the system was suspended) or when the
> > interface is opened by a user at a later time.
> > 
> > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> > ---
> >  drivers/net/ethernet/renesas/ravb_main.c | 72 ++++++++++++++++++++++++++++----
> >  1 file changed, 64 insertions(+), 8 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> > index da8da86..1de55c9 100644
> > --- a/drivers/net/ethernet/renesas/ravb_main.c
> > +++ b/drivers/net/ethernet/renesas/ravb_main.c
> [...]
> > @@ -2111,6 +2166,7 @@ static int ravb_runtime_nop(struct device *dev)
> >  }
> > 
> >  static const struct dev_pm_ops ravb_dev_pm_ops = {
> > +	SET_SYSTEM_SLEEP_PM_OPS(ravb_runtime_suspend, ravb_runtime_resume)
> 
>    Why in the world you used runtime_ in the usual suspend/resume method
> names?! Since DaveM have already taken the patch, please send a follow-up
> patch to remove that infix.

Sorry about that, stupid error on my part. Will send a follow-up patch.  
Thanks for finding it.

> 
> >  	SET_RUNTIME_PM_OPS(ravb_runtime_nop, ravb_runtime_nop, NULL)
> >  };
> > 
> 
> MBR, Sergei
> 

-- 
Regards,
Niklas Söderlund
