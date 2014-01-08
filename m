From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [net-next 2/7] ixgbe: Indicate removal state explicitly
Date: Wed, 8 Jan 2014 00:37:21 -0800
Message-ID: <79DAF37B-9AA5-407B-81D2-3EDFD8589254@gmail.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com> <1389166847-3780-3-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Mark Rustad <mark.d.rustad@intel.com>,
	Netdev <netdev@vger.kernel.org>, gospo@redhat.com,
	sassmann@redhat.com
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38226 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755050AbaAHIhZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 03:37:25 -0500
Received: by mail-ig0-f178.google.com with SMTP id ut6so4018867igb.5
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 00:37:24 -0800 (PST)
In-Reply-To: <1389166847-3780-3-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> wrote:

> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> Add a bit, __IXGBE_REMOVE, to indicate that the module is being
> removed. The __IXGBE_DOWN bit had been overloaded for this purpose,
> but that leads to trouble. A few places now check both __IXGBE_DOWN
> and __IXGBE_REMOVE. Notably, setting either bit will prevent service
> task execution.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
> ---
> drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  1 +
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 12 ++++++++----
> 2 files changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 49531cd..8da263a 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -798,6 +798,7 @@ enum ixgbe_state_t {
> 	__IXGBE_TESTING,
> 	__IXGBE_RESETTING,
> 	__IXGBE_DOWN,
> +	__IXGBE_REMOVE,

__IXGBE_REMOVING?  More consistent with _TESTING, _RESETTING, etc.