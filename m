From: Andrew Morton <akpm@osdl.org>
Subject: Re: "deadlock" between smc91x driver and link_watch
Date: Wed, 24 Nov 2004 01:46:50 -0800
Message-ID: <20041124014650.47af8ae4.akpm@osdl.org>
References: <1101230194.14370.12.camel@icampbell-debian>
	<20041123153158.6f20a7d7.akpm@osdl.org>
	<1101289309.10841.9.camel@icampbell-debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262566AbUKXJrM@vger.kernel.org>
To: Ian Campbell <icampbell@arcom.com>
In-Reply-To: <1101289309.10841.9.camel@icampbell-debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Campbell <icampbell@arcom.com> wrote:
>
>  On Tue, 2004-11-23 at 15:31 -0800, Andrew Morton wrote:
>  > One possible fix would be to remove that flush_scheduled_work() and to do
>  > refcounting around smc_phy_configure(): dev_hold() when scheduling the work
>  > (if schedule_work() returned true), dev_put() in the handler.
> 
>  Something like the following?

I think so.

>  +static void smc_phy_configure_wq(void *data)
>  +{
>  +	struct net_device *dev = data;
>  +	dev_put(dev);
>  +	smc_phy_configure(data);
>  +}

You'd want to do the dev_put() after the smc_phy_configure() though.  It
may still be a tiny bit racy against module unload.
