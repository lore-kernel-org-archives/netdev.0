From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 05/21] atm: he: use mdelay instead of large udelay
 constants
Date: Fri, 26 Apr 2013 09:12:20 -0400
Message-ID: <20130426091220.468cf59e@thirdoffive.cmf.nrl.navy.mil>
References: <1366910944-3033663-1-git-send-email-arnd@arndb.de>
 <1366910944-3033663-6-git-send-email-arnd@arndb.de>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7203@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
 linux-arm-kernel@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>,
 linux-kernel@vger.kernel.org
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7203@saturn3.aculab.com>
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

On Fri, 26 Apr 2013 09:21:59 +0100
"David Laight" <David.Laight@ACULAB.COM> wrote:

> > ARM cannot handle udelay for more than 2 miliseconds, so we
> > should use mdelay instead for those.
> ...
> > @@ -1055,7 +1055,7 @@ static int he_start(struct atm_dev *dev)
> >  	he_writel(he_dev, 0x0, RESET_CNTL);
> >  	he_writel(he_dev, 0xff, RESET_CNTL);
> > 
> > -	udelay(16*1000);	/* 16 ms */
> > +	mdelay(16);	/* 16 ms */
> >  	status = he_readl(he_dev, RESET_CNTL);
> 
> 16ms seems a long time to spin.
> I'd have thought a sleep would be more appropriate.
> Since this looks like timing a hardware reset pulse
> it can't matter if it is somewhat longer.

Yes, I wrote this bit some time ago when I was less wise. The
programmer's guide doesn't say how long to sleep, so the value isn't
critical.  It just has to be "long enough".  An msleep() would be fine
here.
