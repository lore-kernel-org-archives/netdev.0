From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 0/6] slight optimization of addr compare for
 some modules
Date: Wed, 18 Dec 2013 17:35:09 +0800
Message-ID: <52B16C4D.1020807@huawei.com>
References: <52AEB8B3.5010405@huawei.com>	 <1387205111.18217.7.camel@joe-AO722> <52AF13F4.5040409@gmail.com>	 <1387207006.18217.28.camel@joe-AO722> <1387214748.18217.52.camel@joe-AO722>	 <52AFAFDC.2080807@huawei.com> <52B1611E.4090608@huawei.com> <1387358236.13593.36.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dthxman@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:35123 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab3LRJfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:35:36 -0500
In-Reply-To: <1387358236.13593.36.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/18 17:17, Joe Perches wrote:
> On Wed, 2013-12-18 at 16:47 +0800, Ding Tianhong wrote:
>> On 2013/12/17 9:58, Ding Tianhong wrote:
>>> On 2013/12/17 1:25, Joe Perches wrote:
>>>> These should still be inspected for appropriate use of
>>>> ether_addr_equal or ether_addr_equal_unaligned, but a
>>>> better cocci input sp-file is:
>>>>
>>>> $ cat ether_addr_equal_unaligned.cocci 
>>>> @@
>>>> expression e1;
>>>> expression e2;
>>>> @@
> []
>> There are too many places need to be changed, should I make it in one patch or several pathset,
>> pls give me some advise. thanks
> 
> Separate per-maintainer patches are generally good.
> It can take several attempts to get these applied
> in all the various trees.
> 
> So maybe 1 patch for each of most of these.  Maybe
> some of these like drivers/media, drivers/mtd and
> drivers/staging could probably be single patches.
> 
> $ git grep --name-only -E "\bmemcmp\s*\([^,]+,[^,]+,\s*(ETH_ALEN|6)\s*\)"| \
>   sed -r 's@\w+.[ch]$@@' | sort | uniq
> arch/x86/kernel/apic/
> block/partitions/
> drivers/atm/
> drivers/infiniband/hw/mlx4/
> drivers/infiniband/ulp/ipoib/
> drivers/isdn/i4l/
> drivers/media/dvb-core/
> drivers/media/usb/gspca/
> drivers/mtd/
> drivers/mtd/nand/
> drivers/net/bonding/
> drivers/net/ethernet/amd/
> drivers/net/ethernet/atheros/atlx/
> drivers/net/ethernet/broadcom/bnx2x/
> drivers/net/ethernet/chelsio/cxgb3/
> drivers/net/ethernet/cisco/enic/
> drivers/net/ethernet/emulex/benet/
> drivers/net/ethernet/freescale/
> drivers/net/ethernet/intel/igbvf/
> drivers/net/ethernet/mellanox/mlx4/
> drivers/net/ethernet/micrel/
> drivers/net/ethernet/neterion/vxge/vxge-
> drivers/net/ethernet/qlogic/netxen/
> drivers/net/ethernet/qlogic/qlcnic/
> drivers/net/ethernet/renesas/
> drivers/net/ethernet/seeq/
> drivers/net/ethernet/sun/
> drivers/net/ethernet/ti/
> drivers/net/fddi/skfp/
> drivers/net/hamradio/
> drivers/net/plip/
> drivers/net/ppp/
> drivers/net/wireless/
> drivers/net/wireless/ath/ath10k/
> drivers/net/wireless/ath/ath6kl/
> drivers/net/wireless/ath/wcn36xx/
> drivers/net/wireless/ath/wil6210/
> drivers/net/wireless/brcm80211/brcmfmac/
> drivers/net/wireless/cw1200/
> drivers/net/wireless/hostap/
> drivers/net/wireless/ipw2x00/
> drivers/net/wireless/libertas/
> drivers/net/wireless/mwifiex/
> drivers/net/wireless/orinoco/
> drivers/net/wireless/prism54/
> drivers/net/wireless/rtlwifi/
> drivers/net/wireless/ti/wl1251/
> drivers/net/wireless/zd1211rw/
> drivers/s390/net/
> drivers/scsi/sym53c8xx_2/
> drivers/staging/ozwpan/
> drivers/staging/rtl8187se/
> drivers/staging/rtl8187se/ieee80211/
> drivers/staging/rtl8188eu/core/
> drivers/staging/rtl8188eu/os_dep/
> drivers/staging/rtl8192e/
> drivers/staging/rtl8192u/ieee80211/
> drivers/staging/rtl8712/
> drivers/staging/vt6655/
> drivers/staging/vt6656/
> drivers/staging/wlan-ng/
> drivers/target/iscsi/
> drivers/usb/atm/
> drivers/usb/storage/
> drivers/video/matrox/
> fs/sysv/
> include/linux/
> init/
> net/batman-adv/
> net/batman-adv/translation-
> net/bluetooth/bnep/
> net/bluetooth/hidp/
> net/bridge/
> net/caif/
> net/mac80211/
> net/sunrpc/auth_gss/
> scripts/
> 
> 

great, thanks, my team could make it together.

Regards
Ding

> .
> 
