From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: simpler bic default
Date: Tue, 19 Sep 2006 16:02:02 -0700
Message-ID: <20060919160202.23390471@localhost.localdomain>
References: <20060919.142007.06541289.davem@davemloft.net>
	<20060919143209.1164d803@localhost.localdomain>
	<20060919214304.GB13543@outpost.ds9a.nl>
	<20060919.154435.102044066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27859 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752096AbWISXCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 19:02:12 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060919.154435.102044066.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> When TCP_CONG_ADVANCED is disabled, TCP_CONG_BIC should always be set
> and be the default, but that's not what the new code is doing.
> 
> I'm reverting Stephen's patch (again) until this is all sorted
> out as things are still broken in various ways even with the
> followon patch.

I don't see what's wrong, this is on a kernel with the two patches:
 
After "make defconfig"
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_DEFAULT_TCP_CONG="bic"
# CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set
# CONFIG_IP_NF_TARGET_TCPMSS is not set
# CONFIG_ISCSI_TCP is not set

Enable TCP_ADVANCED_CONG with make menuconfig

CONFIG_TCP_CONG_ADVANCED=y
# TCP congestion control
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=m
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
# CONFIG_TCP_CONG_HSTCP is not set
# CONFIG_TCP_CONG_HYBLA is not set
# CONFIG_TCP_CONG_VEGAS is not set
# CONFIG_TCP_CONG_SCALABLE is not set
# CONFIG_TCP_CONG_LP is not set
# CONFIG_TCP_CONG_VENO is not set
# CONFIG_DEFAULT_HTCP is not set
CONFIG_DEFAULT_TCP_CONG="bic"


After "make allmodconfig"
CONFIG_INET_TCP_DIAG=m
CONFIG_TCP_CONG_ADVANCED=y
# TCP congestion control
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=m
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
# CONFIG_DEFAULT_HTCP is not set
CONFIG_DEFAULT_TCP_CONG="reno"

After "make allyesconfig"
CONFIG_INET_TCP_DIAG=y
CONFIG_TCP_CONG_ADVANCED=y
# TCP congestion control
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
# CONFIG_DEFAULT_HTCP is not set
CONFIG_DEFAULT_TCP_CONG="bic"


