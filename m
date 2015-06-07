From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH] wan: dscc4: use msecs_to_jiffies for conversions
Date: Sun, 7 Jun 2015 10:31:37 +0200
Message-ID: <20150607083137.GB9670@opentech.at>
References: <1433580066-1237-1-git-send-email-hofrat@osadl.org> <20150607.001351.1615444562432115091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hofrat@osadl.org, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150607.001351.1615444562432115091.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 07 Jun 2015, David Miller wrote:

> From: Nicholas Mc Guire <hofrat@osadl.org>
> Date: Sat,  6 Jun 2015 10:41:06 +0200
> 
> > API compliance scanning with coccinelle flagged:
> > ./drivers/net/wan/dscc4.c:1036:1-33:
> >         WARNING: timeout (10) seems HZ dependent
> > ./drivers/net/wan/dscc4.c:554:2-34:
> >         WARNING: timeout (10) seems HZ dependent
> > ./drivers/net/wan/dscc4.c:599:2-34:
> >         WARNING: timeout (10) seems HZ dependent
> > 
> > Numeric constants passed to schedule_timeout_*() make the effective
> > timeout HZ dependent which does not seem to be the intent here.
> > Fixed up by converting the constant to jiffies with msecs_to_jiffies()
> > 
> > Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> 
> Whoever wrote these things probably wanted whatever this amounts
> to when HZ=100, so that is the only valid transformation you can
> make to fix this up here.
> 
> Otherwise you seriously risk breaking the driver.

I did not find dscc4 in the 2.2 series of kernels so it does not predate
configurable HZ - or do you mean simply that increasing the timeout
here should be side-effect free and thus the larger of the values
should be taken ? - though that would imply that it is possibly now 
broken for HZ=1000. 

Will fix it up to 10 == 100ms and fix the patch documentation.

thx!
hofrat
