From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH net-next 2/2] net: netcp: select davinci_mdio driver by
 default
Date: Mon, 2 Mar 2015 16:04:45 -0800
Message-ID: <20150303000444.GC3756@atomide.com>
References: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com>
 <1424813251-31610-2-git-send-email-m-karicheri2@ti.com>
 <20150227162921.GX11056@atomide.com>
 <54F0D9E9.1020705@ti.com>
 <20150302161155.GB3665@atomide.com>
 <54F4DA06.9070505@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mugunthanvnm@ti.com,
	prabhakar.csengg@gmail.com, varkabhadram@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	grygorii.strashko@ti.com, lokeshvutla@ti.com, mpa@pengutronix.de,
	w-kwok2@ti.com
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54F4DA06.9070505@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Murali Karicheri <m-karicheri2@ti.com> [150302 13:49]:
> On 03/02/2015 11:11 AM, Tony Lindgren wrote:
> >
> >Because we are now force selecting items that may have other
> >dependencies later on that will not be satisfied. That causes
> >all kinds of make randconfig build errors.
> >
> My mistake.  I didn't ask you what is your definition of a silent option? An
> option not selected by any other option? Or an option for which default
> value not defined? Can you clarify this so that I can make sense of your
> comment? I checked Documentation/kbuild/kconfig.txt as well as
> Documentation/kbuild/kconfig-language.txt for defintion, but can't find it.
> 
> Howeve, I read the warning about using "select" in the above document since
> it blindly select the option without checking dependencies. So AFAIK, select
> becomes an issue if the config option is not the leaf option of the config
> tree as the dependency checking is not in place and can cause issues. In
> this case it is safe as DAVINCI_MDIO is a leaf option and only selects
> PHYLIB which dependents on NETDEVICES and we know this is true for NETCP
> devices. So select is just fine here.

OK I think you're right that in this case it won't cause issues.

But if these cpsw components are never selectable by the user for
any real use case, then you may want to make them silent Kconfig
options:

config TI_DAVINCI_MDIO
	bool
	select PHYLIB

config TI_DAVINCI_CPDMA
	bool

config TI_CPSW_PHY_SEL
	bool

config TI_CPSW_ALE
	bool
...

Regards,

Tony
