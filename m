From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: micrel: support !CONFIG_HAVE_CLK
Date: Mon, 27 Apr 2015 13:40:10 -0400 (EDT)
Message-ID: <20150427.134010.660188516721843373.davem@davemloft.net>
References: <1430132450-4496-1-git-send-email-niklass@axis.com>
	<20150427110517.GA10925@localhost>
	<20150427110807.GB10925@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niklas.cassel@axis.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	niklass@axis.com
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150427110807.GB10925@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Mon, 27 Apr 2015 13:08:07 +0200

> On Mon, Apr 27, 2015 at 01:05:17PM +0200, Johan Hovold wrote:
>> On Mon, Apr 27, 2015 at 01:00:50PM +0200, Niklas Cassel wrote:
>> > Since NULL is a valid clock, we shouldn't use
>> > IS_ERR_OR_NULL.
>> > 
>> > Implemented as Russell King suggested in:
>> > 
>> > http://lkml.kernel.org/r/20150207172949.GE8656@n2100.arm.linux.org.uk
>> > 
>> > Signed-off-by: Niklas Cassel <niklass@axis.com>
>> > ---
>> >  drivers/net/phy/micrel.c | 7 +++++--
>> >  1 file changed, 5 insertions(+), 2 deletions(-)
>> > 
>> > diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> > index 1190fd8..d958d13 100644
>> > --- a/drivers/net/phy/micrel.c
>> > +++ b/drivers/net/phy/micrel.c
>> > @@ -522,6 +522,7 @@ static int kszphy_probe(struct phy_device *phydev)
>> >  	struct device_node *np = phydev->dev.of_node;
>> >  	struct kszphy_priv *priv;
>> >  	struct clk *clk;
>> > +	unsigned long rate = 0;
>> >  	int ret;
>> >  
>> >  	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
>> > @@ -548,8 +549,10 @@ static int kszphy_probe(struct phy_device *phydev)
>> >  	}
>> >  
>> >  	clk = devm_clk_get(&phydev->dev, "rmii-ref");
>> > -	if (!IS_ERR(clk)) {
>> > -		unsigned long rate = clk_get_rate(clk);
>> > +	if (!IS_ERR(clk))
>> > +		rate = clk_get_rate(clk);
>> > +
>> > +	if (rate) {
>> 
>> And how do you expect this to work as clk_get_rate returns -EINVAL when
>> clk is NULL?
>> 
>> Have you not tested your patch?
> 
> Nevermind, it is 0 if !CONFIG_HAVE_CLK, but still does not look like the
> right fix.

Agreed, this doesn't look right to me either.
