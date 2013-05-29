From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCHv2 1/3] net: phy: prevent linking breakage
Date: Wed, 29 May 2013 10:21:26 +0200
Message-ID: <51A5BA86.3070609@free-electrons.com>
References: <1369741403-25315-1-git-send-email-alexandre.belloni@free-electrons.com> <1369741403-25315-2-git-send-email-alexandre.belloni@free-electrons.com> <20130528.130920.1604291112518863799.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	shawn.guo@linaro.org, kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130528.130920.1604291112518863799.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 28/05/2013 22:09, David Miller wrote:
>
> This is the wrong way to go about this.
>
> If the arch code absolutely requires CONFIG_PHYLIB=y then express that
> dependency in the arch Kconfig.  The arch code in question should not
> be compiled at all if CONFIG_PHYLIB has an incompatible setting.
But that is making it impossible to compile a kernel without any network
stack for those platforms or we are going back to either enclosing the
calls to phy_register_fixup{,_for_uid,_for_id} with #ifdef CONFIG_PHYLIB
or if(IS_BUILTIN(CONFIG_PHYLIB)). And as you can see, it is quite error
prone and is done only done for 2 platforms on a total of 6. I believe
fixing that in phy.h is more foolproof.

Regards,

-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
