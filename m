From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: simpler bic default
Date: Tue, 19 Sep 2006 16:04:41 -0700 (PDT)
Message-ID: <20060919.160441.66322371.davem@davemloft.net>
References: <20060919214304.GB13543@outpost.ds9a.nl>
	<20060919.154435.102044066.davem@davemloft.net>
	<20060919160202.23390471@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60616
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751353AbWISXEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 19:04:36 -0400
To: shemminger@osdl.org
In-Reply-To: <20060919160202.23390471@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 19 Sep 2006 16:02:02 -0700

> 
> > When TCP_CONG_ADVANCED is disabled, TCP_CONG_BIC should always be set
> > and be the default, but that's not what the new code is doing.
> > 
> > I'm reverting Stephen's patch (again) until this is all sorted
> > out as things are still broken in various ways even with the
> > followon patch.
> 
> I don't see what's wrong, this is on a kernel with the two patches:

Look more closely:

> After "make defconfig"
> # CONFIG_TCP_CONG_ADVANCED is not set
> CONFIG_DEFAULT_TCP_CONG="bic"
> # CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set
> # CONFIG_IP_NF_TARGET_TCPMSS is not set
> # CONFIG_ISCSI_TCP is not set

But TCP_CONG_BIC isn't enabled so it won't get built nor be
the default algorithm.  When CONG_ADVANCED is off, as it is here,
TCP_CONG_BIC should be "y".  That's what happens before your
changes.
