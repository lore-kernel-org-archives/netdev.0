From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH wireless-next 18/20] ti: Use pr_<level>
Date: Fri, 15 Jun 2012 03:42:11 -0700
Message-ID: <1339756931.24527.16.camel@joe2Laptop>
References: <cover.1339739415.git.joe@perches.com>
	 <a4533db379be3689e3b29ed9b0d170263d875f7d.1339739416.git.joe@perches.com>
	 <1339749374.4502.80.camel@cumari.coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339749374.4502.80.camel@cumari.coelho.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-15 at 11:36 +0300, Luciano Coelho wrote:
> Hi Joe,

Hi Luciano.

> As Johannes already mentioned, I have to also ask why do you need to do
> this?

To use a more consistent logging style.
To minimize unnecessary changes when adding
similar drivers based on this code.

>  I see the point, slightly, with the wl1251 code, because it is
> still using printks, but with wlcore and friends, there's no functional
> change.

Using a consistent logging style minimizes defects.

> As mentioned above, this change here is acceptable, but removing the \n
> from the macro and adding it at the end of each and every call is
> useless and will just skew git-blame and make it harder to do rebase or
> apply patches because of conflicts.

In practice, the merging won't be much of an issue.
Neither will git blame.

> > -#define wl1271_warning(fmt, arg...) \
> > -	pr_warning(DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
> > +#define wl1271_warn(fmt, arg...)				\
> > +	pr_warn(DRIVER_PREFIX "WARNING " fmt, ##arg)
> 
> Using pr_warn instead of pr_warning is pointless.  pr_warning is the
> main definition, actually, and pr_warn is just a "mirror".

I expect one day to reverse the definitions.

The kernel is moving, albeit slowly to prefer
pr_warn to mirror dev_warn, netdev_warn, etc.

Most of these uses will eventually become netdev_warn.
netdev_warn still uses a \n.

> Again, moving the \n from the macro definition and changing all the
> callers is an unnecessary, intrusive change.
> 
> We have wanted to change "wl1271" to "wl12xx" for a long time, but we
> don't do it exactly because this means we need to change the calls
> everywhere.

Nothing in ever _needed_, no child will go
hungry or fed here.  This is a consistency change.

There are a couple of instances where \n is
currently used unnecessarily that are fixed in
the conversion.

$ git grep -E  "\bwl12[0-9]+_[a-z]+\s*\(.*\\\\n\"" drivers/net/wireless/ti
drivers/net/wireless/ti/wl12xx/cmd.c:   wl1271_debug(DEBUG_CMD, "FEM autodetect: %s, manufacturer: %d\n",
drivers/net/wireless/ti/wl12xx/cmd.c:   wl1271_debug(DEBUG_CMD, "FEM autodetect: %s, manufacturer: %d\n",
drivers/net/wireless/ti/wlcore/main.c:          wl1271_error("Incorrect ampdu action id=%x\n", action);

People make these mistakes because the more
common and adjacent dev_<level> code _use_
a newline.  Using a consistent style minimzes
these defects.

cheers, Joe
