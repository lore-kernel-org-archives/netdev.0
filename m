From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [sfc:master 79/80] drivers/net/ethernet/sfc/mcdi.c:960:1:
 warning: 'efx_mcdi_print_fwver' uses dynamic stack allocation
Date: Mon, 2 Sep 2013 19:35:12 +0100
Message-ID: <1378146912.1552.29.camel@bwh-desktop.uk.level5networks.com>
References: <5221261c.gkIQ84VFSaPYEYzp%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <kbuild-all@01.org>, netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23512 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758926Ab3IBSfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 14:35:17 -0400
In-Reply-To: <5221261c.gkIQ84VFSaPYEYzp%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-31 at 07:09 +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next master
> head:   f7a6d2c4427790cc8695401576dc594fcce8fc80
> commit: 8127d661e77f5ec410093bce411f540afa34593f [79/80] sfc: Add support for Solarflare SFC9100 family
> config: make ARCH=s390 allmodconfig
> 
> All warnings:
> 
>    drivers/net/ethernet/sfc/mcdi.c: In function 'efx_mcdi_print_fwver':
> >> drivers/net/ethernet/sfc/mcdi.c:960:1: warning: 'efx_mcdi_print_fwver' uses dynamic stack allocation [enabled by default]
[...]

What we actually do is:

	MCDI_DECLARE_BUF(outbuf,
			 max(MC_CMD_GET_VERSION_OUT_LEN,
			     MC_CMD_GET_CAPABILITIES_OUT_LEN));

The dimension of the outbuf array is constant, even though max() doesn't
expand to a compile-time constant expression.  It's odd that gcc would
complain about this specifically on s390 (or is it that you're using a
different compiler version there?).  I don't know whether anything can
or should be done about to fix the warning.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
