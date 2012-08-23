From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: add new QCA alx ethernet driver
Date: Wed, 22 Aug 2012 22:57:00 -0700 (PDT)
Message-ID: <20120822.225700.714020017287504609.davem@davemloft.net>
References: <1345480949-14800-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	xiong@qca.qualcomm.com, rodrigue@qca.qualcomm.com
To: cjren@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345480949-14800-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <cjren@qca.qualcomm.com>
Date: Tue, 21 Aug 2012 00:42:29 +0800

> +config ALX_DEBUGFS
> +	bool "Qualcomm Atheros debugging interface"
> +	depends on ALX && DEBUG_FS
> +	---help---
> +	  This option adds ability to debug and test L1F. It can
> +	  support Qualcomm Atheros tools, including diagnostic, memcfg
> +	  and SWOI.

Sorry, no vendor specific interfaces, you have to remove this.

Anything diagnostic you think is special and unique to your piece of
hardware, is almost certainly not, and therefore needs to exist as a
generic ethtool or similar interface that other drivers can plug into,
not just your's.

Driver specific interfaces suck for several reasons, not least of
which is the fact that it leads to a terrible user experience.  The
same task must be done in different ways depending upon what piece of
networking hardware and device driver are being used, which the user
should never need to know.

This is why we require that portable, sane, interfaces are added
to ethtool for driver diagnostics.  That way users can perform
a task in the same way regardless of what hardware and driver
are underneath.
