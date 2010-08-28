From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH 3/7] drivers/net/atl1c: Remove double test
Date: Sat, 28 Aug 2010 13:10:01 -0700
Message-ID: <20100828201001.GA9287@tux>
References: <1283010066-20935-1-git-send-email-julia@diku.dk>
 <1283010066-20935-4-git-send-email-julia@diku.dk>
 <20100828165014.GJ9832@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Dan Carpenter <error27@gmail.com>, Julia Lawall <julia@diku.dk>,
	<netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <Jie.Yang@atheros.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100828165014.GJ9832@bicker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 28, 2010 at 09:50:14AM -0700, Dan Carpenter wrote:
> I added the Atheros people to the CC list.  Jie Yang should know.
> 
> regards,
> dan carpenter
> 
> On Sat, Aug 28, 2010 at 05:41:02PM +0200, Julia Lawall wrote:
> > The nic_type field is compared to athr_l2c twice.
> > 
> > The sematic match that finds this problem is as follows:
> > (http://coccinelle.lip6.fr/)
> > 
> > // <smpl>
> > @expression@
> > expression E;
> > @@
> > 
> > (
> > * E
> >   || ... || E
> > |
> > * E
> >   && ... && E
> > )
> > // </smpl>
> > 
> > Signed-off-by: Julia Lawall <julia@diku.dk>
> > 
> > ---
> > This is a guess as to what the code should be.  Perhaps something else
> > should have been tested instead.
> > 
> >  drivers/net/atl1c/atl1c_hw.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/atl1c/atl1c_hw.c b/drivers/net/atl1c/atl1c_hw.c
> > index d8501f0..919080b 100644
> > --- a/drivers/net/atl1c/atl1c_hw.c
> > +++ b/drivers/net/atl1c/atl1c_hw.c
> > @@ -480,7 +480,7 @@ int atl1c_phy_reset(struct atl1c_hw *hw)
> >  		atl1c_write_phy_reg(hw, MII_DBG_DATA, 0x929D);
> >  	}
> >  	if (hw->nic_type == athr_l1c || hw->nic_type == athr_l2c_b2
> > -		|| hw->nic_type == athr_l2c || hw->nic_type == athr_l2c) {
> > +		|| hw->nic_type == athr_l2c) {
> >  		atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x29);
> >  		atl1c_write_phy_reg(hw, MII_DBG_DATA, 0xB6DD);
> >  	}

The patch is pretty obvious. Looks good.

  Luis
