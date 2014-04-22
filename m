From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] iproute2: v3: Add support to configure SR-IOV VF
 minimum and maximum Tx rate through ip tool.
Date: Tue, 22 Apr 2014 15:40:51 -0700
Message-ID: <20140422154051.26e584ce@nehalam.linuxnetplumber.net>
References: <1397450220-8269-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	<ben@decadent.org.uk>, <gregory.v.rose@intel.com>,
	<linux-net-drivers@solarflare.com>, <Ariel.Elior@qlogic.com>,
	<amirv@mellanox.com>, <mkubecek@suse.cz>
To: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43167 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaDVWky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 18:40:54 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so97876pad.1
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 15:40:54 -0700 (PDT)
In-Reply-To: <1397450220-8269-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Apr 2014 00:37:00 -0400
Sucheta Chakraborty <sucheta.chakraborty@qlogic.com> wrote:

> o "min_tx_rate" option has been added for minimum Tx rate. Hence, for
>   consistent naming, "max_tx_rate" option has been introduced for maximum
>   Tx rate.
> 
> o Change in v2: "rate" can be used along with "max_tx_rate".
>   When both are specified, "max_tx_rate" should override.
> 
> o Change in v3:
>   * IFLA_VF_RATE: When IFLA_VF_RATE is used, and user has given only one of
>     min_tx_rate or max_tx_rate, reading of previous rate limits is done in
>     userspace instead of in kernel space before ndo_set_vf_rate.
> 
>   * IFLA_VF_TX_RATE: When IFLA_VF_TX_RATE is used, min_tx_rate is always read
>     in kernel space. This takes care of below scenarios:
>     (1) when old tool sends "rate" but kernel is new (expects min and max)
>     (2) when new tool sends only "rate" but kernel is old (expects only "rate")
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

I like the concept fine, but the general policy of ip route commands is
that the output format should match the input (except for statistics).

This (and ther earlier tx_rate patch are printing values in a different format
than the input

i.e don't print:
	max tx rate 110 (Mbps)
instead print:
	max_tx_rate 110Mbps


	
