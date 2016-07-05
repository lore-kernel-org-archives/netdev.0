From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 3/5] drivers: net: phy: Add MDIO driver
Date: Tue, 5 Jul 2016 15:49:50 +0200
Message-ID: <20160705134950.GC5230@lunn.ch>
References: <1464739840-21971-1-git-send-email-isubramanian@apm.com>
 <1464739840-21971-4-git-send-email-isubramanian@apm.com>
 <20160601011148.GD31982@lunn.ch>
 <CAKh23FmaQy8J=f-eyfBeNndz0oT5R0icvwJ3vrw1DMJnj9uv_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 netdev <netdev@vger.kernel.org>, patches <patches@apm.com>,
 Matthias Brugger <matthias.bgg@gmail.com>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CAKh23FmaQy8J=f-eyfBeNndz0oT5R0icvwJ3vrw1DMJnj9uv_g@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 10:12:35AM -0700, Iyappan Subramanian wrote:
> Hi Andrew,
> 
> Thanks for the review.
> 
> On Tue, May 31, 2016 at 6:11 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> > On Tue, May 31, 2016 at 05:10:38PM -0700, Iyappan Subramanian wrote:
> >> +static int xgene_mdio_reset(struct xgene_mdio_pdata *pdata)
> >> +{
> >> +     int ret;
> >> +
> >> +     if (pdata->mdio_id == XGENE_MDIO_RGMII) {
> >> +             if (pdata->dev->of_node) {
> >> +                     clk_prepare_enable(pdata->clk);
> >> +                     clk_disable_unprepare(pdata->clk);
> >> +                     clk_prepare_enable(pdata->clk);
> >
> > Hi Iyappan
> >
> > Is that a workaround for a hardware problem? If so, i would suggest
> > adding a comment, to stop people submitting a patch simplifying it.
> 
> Hardware expects this clock sequence.  I'll add comment as you suggested.

What exactly does the hardware require? Is this a workaround for a bug
in the clock generator? Or a workaround for a bug in the MDIO device?

If it is a clock generator bug, i think the fix should be in the clock
driver. If this is bug in the MDIO device, do you need a sleep in
there, so you actually have the clock ticking/not ticking for a time?
Since these calls can all sleep, you have no idea how long/sort the
clock will be enabled/disabled.

      Andrew
