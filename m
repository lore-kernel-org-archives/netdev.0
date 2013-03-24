From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: put tx to napi poll function
 to fix dead lock
Date: Sun, 24 Mar 2013 22:35:28 +0800
Message-ID: <20130324143525.GI6281@S2101-09.ap.freescale.net>
References: <1362368065-5809-1-git-send-email-Frank.Li@freescale.com>
 <20130320114824.GA6088@S2101-09.ap.freescale.net>
 <CAOMZO5B-ipzyb2uiLW12fFd3PD3JfLS8R0YLM5vtLgFNz8abUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Li <Frank.Li@freescale.com>, <B38611@freescale.com>,
	<netdev@vger.kernel.org>, <s.hauer@pengutronix.de>,
	<lznuaa@gmail.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:50077
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753900Ab3CXOfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 10:35:25 -0400
Content-Disposition: inline
In-Reply-To: <CAOMZO5B-ipzyb2uiLW12fFd3PD3JfLS8R0YLM5vtLgFNz8abUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 22, 2013 at 04:00:26PM -0300, Fabio Estevam wrote:
> On Wed, Mar 20, 2013 at 8:48 AM, Shawn Guo <shawn.guo@linaro.org> wrote:
> > Frank,
> >
> > I'm running v3.9-rc3 image with NFS on imx6q, and seeing system fail
> > to resume back.  The resume seems being stopped by fec driver.  If you
> > wait long enough, you might see the repeated "eth0: tx queue full!."
> > error message.
> 
> On mx28, only reverting this patch does not solve the suspend/resume issue.

Are you sure?  After reverting the patch on next-20130322, I can get
imx28 resume back to console as below.

Shawn

root@freescale ~$ echo mem > /sys/power/state
[   20.943170] PM: Syncing filesystems ... done.
[   20.976303] Freezing user space processes ... (elapsed 0.01 seconds) done.
[   20.998050] Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
[   21.025647] PM: suspend of devices complete after 6.283 msecs
[   21.032543] PM: late suspend of devices complete after 1.092 msecs
[   21.040489] PM: noirq suspend of devices complete after 1.603 msecs
[   21.048045] PM: noirq resume of devices complete after 0.794 msecs
[   21.055891] PM: early resume of devices complete after 1.088 msecs
[   21.167790] PM: resume of devices complete after 105.641 msecs
[   21.174939] Restarting tasks ... done.
root@freescale ~$
