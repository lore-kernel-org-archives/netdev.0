From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next V2 5/6] e1000: call
 ndo_stop()	instead of dev_close() when running offline selftest
Date: Fri, 12 Feb 2016 23:20:51 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E89BE2@ORSMSX101.amr.corp.intel.com>
References: <1454487652-1545-1-git-send-email-sassmann@kpanic.de>,<1454487652-1545-6-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stefan Assmann <sassmann@kpanic.de>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:47253 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbcBLXVE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 18:21:04 -0500
In-Reply-To: <1454487652-1545-6-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [intel-wired-lan-bounces@lists.osuosl.org] on behalf of Stefan Assmann [sassmann@kpanic.de]
> Sent: Wednesday, February 03, 2016 12:20 AM
> To: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org; davem@davemloft.net; sassmann@kpanic.de
> Subject: [Intel-wired-lan] [PATCH net-next V2 5/6] e1000: call ndo_stop()       instead of dev_close() when running offline selftest
> 
> Calling dev_close() causes IFF_UP to be cleared which will remove the
> interfaces routes and some addresses. That's probably not what the user
> intended when running the offline selftest. Besides this does not happen
> if the interface is brought down before the test, so the current
> behaviour is inconsistent.
> Instead call the net_device_ops ndo_stop function directly and avoid
> touching IFF_UP at all.
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/e1000/e1000.h         | 2 ++
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 4 ++--
>  drivers/net/ethernet/intel/e1000/e1000_main.c    | 8 ++++----
>  3 files changed, 8 insertions(+), 6 deletions(-)

Checkpatch warns that externs should be avoided in .c files, but they pre-existed and are just being flagged due to the name changing, so...

Tested-by: Aaron Brown <aaron.f.brown@intel.com> 
