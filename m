From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next V2 6/6] e1000e: call
 ndo_stop()	instead of dev_close() when running offline selftest
Date: Fri, 12 Feb 2016 23:17:09 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E89BCE@ORSMSX101.amr.corp.intel.com>
References: <1454487652-1545-1-git-send-email-sassmann@kpanic.de>,<1454487652-1545-7-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stefan Assmann <sassmann@kpanic.de>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46490 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbcBLXRL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 18:17:11 -0500
In-Reply-To: <1454487652-1545-7-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [intel-wired-lan-bounces@lists.osuosl.org] on behalf of Stefan Assmann [sassmann@kpanic.de]
> Sent: Wednesday, February 03, 2016 12:20 AM
> To: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org; davem@davemloft.net; sassmann@kpanic.de
> Subject: [Intel-wired-lan] [PATCH net-next V2 6/6] e1000e: call ndo_stop()      instead of dev_close() when running offline selftest
> 
> Calling dev_close() causes IFF_UP to be cleared which will remove the
> interfaces routes and some addresses. That's probably not what the user
> intended when running the offline selftest. Besides this does not happen
> if the interface is brought down before the test, so the current
> behaviour is inconsistent.
> Instead call the net_device_ops ndo_stop function directly and avoid
> touching IFF_UP at all.
> 
> V2: rename e1000_open(), e1000_close() to e1000e_open(), e1000e_close()
> to avoid name clash with e1000.
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/e1000e/e1000.h   |  2 ++
>  drivers/net/ethernet/intel/e1000e/ethtool.c |  4 ++--
>  drivers/net/ethernet/intel/e1000e/netdev.c  | 12 ++++++------
>  3 files changed, 10 insertions(+), 8 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
