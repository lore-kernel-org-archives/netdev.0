From: Joe Perches <joe@perches.com>
Subject: RE: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161
 Ethernet driver
Date: Wed, 19 Oct 2011 00:56:06 -0700
Message-ID: <1319010966.14493.5.camel@Joe-Laptop>
References: <1319009213-20627-1-git-send-email-cloud.ren@atheros.com>
	 <20111019.033324.1233460304204609569.davem@davemloft.net>
	 <6349D7A510622448B1BA0967850A8438011CBA5D@nasanexd02d.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6349D7A510622448B1BA0967850A8438011CBA5D@nasanexd02d.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> ----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> From: <cloud.ren@Atheros.com>
> Date: Wed, 19 Oct 2011 15:26:53 +0800
> > +#define HW_PRINT(_klv, _fmt, _args...) \
> > +	if (ALX_HW_MSG_LV_##_klv || ALX_HW_MSG_LV_ALL) {\
> > +		printk(KERN_##_klv ALX_HW_MSG_PFX_NAME "%s: " _fmt, \
> > +			__func__, ## _args); \
> > +	}
> Do not create your own network driver debugging facilities and macros
> for logging messages, we have rich debugging and logging level
> interfaces that network drivers can use exactly for this purpose.

On Wed, 2011-10-19 at 07:44 +0000, Ren, Cloud wrote:
> Ok. What logging interfaces can I use? Are they dev_err, dev_info and
dev_warn ? thanks

Add and use #define pr_fmt

Logging functions/macros are:

pr_<level>(fmt, ...)
dev_<level>(struct device *, fmt, ...)
netdev_<level>(struct net_device *, fmt, ...)
netif_<level>(priv, type, struct net_device *, fmt, ...)

You chose to add __func__ to all of this output.
I don't think that's particularly valuable.
