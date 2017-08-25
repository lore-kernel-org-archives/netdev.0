From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] staging: rtlwifi: Improve debugging by using debugfs
Date: Fri, 25 Aug 2017 16:16:47 +0200
Message-ID: <20170825141647.GA30922@lunn.ch>
References: <20170824212808.26632-1-Larry.Finger@lwfinger.net>
 <20170825015421.GA8852@lunn.ch>
 <1a1ca849-3aec-60e3-b5a3-98a6e095d298@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Yan-Hsuan Chuang <yhchuang@realtek.com>,
 gregkh@linuxfoundation.org, Birming Chiu <birming@realtek.com>,
 netdev@vger.kernel.org, Steven Ting <steventing@realtek.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1a1ca849-3aec-60e3-b5a3-98a6e095d298@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2017 at 08:47:00AM -0500, Larry Finger wrote:
> On 08/24/2017 08:54 PM, Andrew Lunn wrote:
> >netdev frowns upon debugfs. You should try to keep this altogether,
> >making it easy to throw away before the driver is moved out of
> >staging.
> >
> >You might want to look at ethtool -d. That will be accepted.
> 
> Andrew,
> 
> What is the problem with debugfs?

You should probably look back in the discussions on the netdev
mailling list. But basically, anything you want to export should
follow generic well defined interface, which can be used by other
drivers. debugfs tends to be a mess, a wild west, each driver doing
its own thing, not standardisation. It is O.K. for your own
development work, you can have your own out of tree patches adding in
debugfs, but such patches are unlikely to be accepted into mainline.
David has threatened to simply rip out all debugfs code from all
network drivers. There is push back on adding any new debugfs code,
and some driver writers have taken out debugfs code in their own
drivers, often replacing it with something generic all drivers can
use.
 
> Please suggest which driver has the best example of an ethtool -d
> implementation that we might study.

The API is very simple. In your ethtool_ops you need to function:
.get_regs_len, returns an int, the number of registers you can dump.
.get_regs returns the contents.

There are plenty of examples, e.g.:

http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/amd/pcnet32.c#L1436
 
If you need something more structured, look around, see if other
drivers have similar needs, and propose something generic.

> The first version of the debugfs changes were sent to wireless-drivers on
> July 2. Why are we first hearing of this objection nearly 2 months later?

Different reviewers tend to review different things. I personally
don't care so much who the vendor is, but look out for some specific
things i feel qualified to review. Ethernet PHYs and MDIO drivers,
drivers which make use of Ethernet PHYs, APIs which allow userspace to
write to registers, debugfs, changing MTUs, etc.

There are plenty of patches on netdev for me to review, so i don't
cast a wider net to other lists, like for example wireless-drivers.
You would of got this comment sooner or later, since you should be
posting to netdev at some point anyway. I can also imaging there is
also some reluctance to review staging code, until it is getting close
to moving out of staging.

	Andrew
