From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: [net-next:master 97/110] drivers/net/usb/smsc95xx.c:1073
 smsc95xx_suspend() error: not allocating enough data 4 vs 2
Date: Thu, 1 Nov 2012 12:45:23 +0800
Message-ID: <20121101044523.GB16883@yliu-dev.sh.intel.com>
References: <5091fcca.Ioo8aketSQZU7jtf%yuanhan.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuanhan Liu <yuanhan.liu@linux.intel.com>,
	changlongx.xie@intel.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47738 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070Ab2KAEpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 00:45:16 -0400
Content-Disposition: inline
In-Reply-To: <5091fcca.Ioo8aketSQZU7jtf%yuanhan.liu@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Steve,

FYI, there are new smatch warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   810b6d7638a288216f99bd190470d67061c8bd88
commit: bbd9f9ee69242f23c6063f0102bbb98f5bd23521 [97/110] smsc95xx: add wol support for more frame types

+ drivers/net/usb/smsc95xx.c:1073 smsc95xx_suspend() error: not allocating enough data 4 vs 2
  drivers/net/usb/smsc95xx.c:1074 smsc95xx_suspend() error: not allocating enough data 4 vs 2
+ drivers/net/usb/smsc95xx.c:1081 smsc95xx_suspend() error: potential null dereference 'filter_mask'.  (kzalloc returns null)
+ drivers/net/usb/smsc95xx.c:1085 smsc95xx_suspend() error: potential null dereference 'command'.  (kzalloc returns null)
+ drivers/net/usb/smsc95xx.c:1086 smsc95xx_suspend() error: potential null dereference 'offset'.  (kzalloc returns null)
+ drivers/net/usb/smsc95xx.c:1087 smsc95xx_suspend() error: potential null dereference 'crc'.  (kzalloc returns null)
+ drivers/net/usb/smsc95xx.c:1107 smsc95xx_suspend() error: buffer overflow 'filter_mask' 8 <= 8
  drivers/net/usb/smsc95xx.c:1108 smsc95xx_suspend() error: buffer overflow 'filter_mask' 8 <= 9
  drivers/net/usb/smsc95xx.c:1109 smsc95xx_suspend() error: buffer overflow 'filter_mask' 8 <= 10
  drivers/net/usb/smsc95xx.c:1110 smsc95xx_suspend() error: buffer overflow 'filter_mask' 8 <= 11
  drivers/net/usb/smsc95xx.c:1119 smsc95xx_suspend() error: buffer overflow 'filter_mask' 8 <= 12
  drivers/net/usb/smsc95xx.c:1120 smsc95xx_suspend() error: buffer overflow 'filter_mask' 8 <= 13
  drivers/net/usb/smsc95xx.c:1121 smsc95xx_suspend() error: buffer overflow 'filter_mask' 8 <= 14
  drivers/net/usb/smsc95xx.c:1122 smsc95xx_suspend() error: buffer overflow 'filter_mask' 8 <= 15
+ drivers/net/usb/smsc95xx.c:1131 smsc95xx_suspend() warn: possible memory leak of 'command'
+ drivers/net/usb/smsc95xx.c:1131 smsc95xx_suspend() warn: possible memory leak of 'crc'
+ drivers/net/usb/smsc95xx.c:1131 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1136 smsc95xx_suspend() warn: possible memory leak of 'crc'
+ drivers/net/usb/smsc95xx.c:1136 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1136 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1141 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1141 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1141 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1146 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1146 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1146 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1151 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1151 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1151 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1151 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1156 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1156 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1156 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1156 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1162 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1162 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1162 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1162 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1167 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1167 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1167 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1167 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1172 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1172 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1172 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1172 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1191 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1191 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1191 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1191 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1195 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1195 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1195 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1195 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1200 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1200 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1200 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1200 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1209 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1209 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1209 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1209 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1215 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1215 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1215 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1215 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1221 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1221 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1221 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1221 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1225 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1225 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1225 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1225 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1229 smsc95xx_suspend() warn: possible memory leak of 'command'
  drivers/net/usb/smsc95xx.c:1229 smsc95xx_suspend() warn: possible memory leak of 'crc'
  drivers/net/usb/smsc95xx.c:1229 smsc95xx_suspend() warn: possible memory leak of 'filter_mask'
  drivers/net/usb/smsc95xx.c:1229 smsc95xx_suspend() warn: possible memory leak of 'offset'
  drivers/net/usb/smsc95xx.c:1265 smsc95xx_resume() info: ignoring unreachable code.
  drivers/net/usb/smsc95xx.c:1265 smsc95xx_resume() info: ignoring unreachable code.

vim +1073 drivers/net/usb/smsc95xx.c

e0e474a8 Steve Glendinning 2012-09-28  1067  
e0e474a8 Steve Glendinning 2012-09-28  1068  		return 0;
e0e474a8 Steve Glendinning 2012-09-28  1069  	}
e0e474a8 Steve Glendinning 2012-09-28  1070  
bbd9f9ee Steve Glendinning 2012-10-26  1071  	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
bbd9f9ee Steve Glendinning 2012-10-26  1072  		u32 *filter_mask = kzalloc(32, GFP_KERNEL);
bbd9f9ee Steve Glendinning 2012-10-26 @1073  		u32 *command = kzalloc(2, GFP_KERNEL);
bbd9f9ee Steve Glendinning 2012-10-26  1074  		u32 *offset = kzalloc(2, GFP_KERNEL);
bbd9f9ee Steve Glendinning 2012-10-26  1075  		u32 *crc = kzalloc(4, GFP_KERNEL);
bbd9f9ee Steve Glendinning 2012-10-26  1076  		int i, filter = 0;
bbd9f9ee Steve Glendinning 2012-10-26  1077  
bbd9f9ee Steve Glendinning 2012-10-26  1078  		if (pdata->wolopts & WAKE_BCAST) {
bbd9f9ee Steve Glendinning 2012-10-26  1079  			const u8 bcast[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
bbd9f9ee Steve Glendinning 2012-10-26  1080  			netdev_info(dev->net, "enabling broadcast detection");
bbd9f9ee Steve Glendinning 2012-10-26 @1081  			filter_mask[filter * 4] = 0x003F;
bbd9f9ee Steve Glendinning 2012-10-26  1082  			filter_mask[filter * 4 + 1] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1083  			filter_mask[filter * 4 + 2] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1084  			filter_mask[filter * 4 + 3] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26 @1085  			command[filter/4] |= 0x05UL << ((filter % 4) * 8);
bbd9f9ee Steve Glendinning 2012-10-26 @1086  			offset[filter/4] |= 0x00 << ((filter % 4) * 8);
bbd9f9ee Steve Glendinning 2012-10-26 @1087  			crc[filter/2] |= smsc_crc(bcast, 6, filter);
bbd9f9ee Steve Glendinning 2012-10-26  1088  			filter++;
bbd9f9ee Steve Glendinning 2012-10-26  1089  		}
bbd9f9ee Steve Glendinning 2012-10-26  1090  
bbd9f9ee Steve Glendinning 2012-10-26  1091  		if (pdata->wolopts & WAKE_MCAST) {
bbd9f9ee Steve Glendinning 2012-10-26  1092  			const u8 mcast[] = {0x01, 0x00, 0x5E};
bbd9f9ee Steve Glendinning 2012-10-26  1093  			netdev_info(dev->net, "enabling multicast detection");
bbd9f9ee Steve Glendinning 2012-10-26  1094  			filter_mask[filter * 4] = 0x0007;
bbd9f9ee Steve Glendinning 2012-10-26  1095  			filter_mask[filter * 4 + 1] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1096  			filter_mask[filter * 4 + 2] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1097  			filter_mask[filter * 4 + 3] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1098  			command[filter/4] |= 0x09UL << ((filter % 4) * 8);
bbd9f9ee Steve Glendinning 2012-10-26  1099  			offset[filter/4] |= 0x00  << ((filter % 4) * 8);
bbd9f9ee Steve Glendinning 2012-10-26  1100  			crc[filter/2] |= smsc_crc(mcast, 3, filter);
bbd9f9ee Steve Glendinning 2012-10-26  1101  			filter++;
bbd9f9ee Steve Glendinning 2012-10-26  1102  		}
bbd9f9ee Steve Glendinning 2012-10-26  1103  
bbd9f9ee Steve Glendinning 2012-10-26  1104  		if (pdata->wolopts & WAKE_ARP) {
bbd9f9ee Steve Glendinning 2012-10-26  1105  			const u8 arp[] = {0x08, 0x06};
bbd9f9ee Steve Glendinning 2012-10-26  1106  			netdev_info(dev->net, "enabling ARP detection");
bbd9f9ee Steve Glendinning 2012-10-26 @1107  			filter_mask[filter * 4] = 0x0003;
bbd9f9ee Steve Glendinning 2012-10-26  1108  			filter_mask[filter * 4 + 1] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1109  			filter_mask[filter * 4 + 2] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1110  			filter_mask[filter * 4 + 3] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1111  			command[filter/4] |= 0x05UL << ((filter % 4) * 8);
bbd9f9ee Steve Glendinning 2012-10-26  1112  			offset[filter/4] |= 0x0C << ((filter % 4) * 8);
bbd9f9ee Steve Glendinning 2012-10-26  1113  			crc[filter/2] |= smsc_crc(arp, 2, filter);
bbd9f9ee Steve Glendinning 2012-10-26  1114  			filter++;
bbd9f9ee Steve Glendinning 2012-10-26  1115  		}
bbd9f9ee Steve Glendinning 2012-10-26  1116  
bbd9f9ee Steve Glendinning 2012-10-26  1117  		if (pdata->wolopts & WAKE_UCAST) {
bbd9f9ee Steve Glendinning 2012-10-26  1118  			netdev_info(dev->net, "enabling unicast detection");
bbd9f9ee Steve Glendinning 2012-10-26  1119  			filter_mask[filter * 4] = 0x003F;
bbd9f9ee Steve Glendinning 2012-10-26  1120  			filter_mask[filter * 4 + 1] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1121  			filter_mask[filter * 4 + 2] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1122  			filter_mask[filter * 4 + 3] = 0x00;
bbd9f9ee Steve Glendinning 2012-10-26  1123  			command[filter/4] |= 0x01UL << ((filter % 4) * 8);
bbd9f9ee Steve Glendinning 2012-10-26  1124  			offset[filter/4] |= 0x00 << ((filter % 4) * 8);
bbd9f9ee Steve Glendinning 2012-10-26  1125  			crc[filter/2] |= smsc_crc(dev->net->dev_addr, ETH_ALEN, filter);
bbd9f9ee Steve Glendinning 2012-10-26  1126  			filter++;
bbd9f9ee Steve Glendinning 2012-10-26  1127  		}
bbd9f9ee Steve Glendinning 2012-10-26  1128  
bbd9f9ee Steve Glendinning 2012-10-26  1129  		for (i = 0; i < (pdata->wuff_filter_count * 4); i++) {
bbd9f9ee Steve Glendinning 2012-10-26  1130  			ret = smsc95xx_write_reg(dev, WUFF, filter_mask[i]);
bbd9f9ee Steve Glendinning 2012-10-26 @1131  			check_warn_return(ret, "Error writing WUFF");
bbd9f9ee Steve Glendinning 2012-10-26  1132  		}
bbd9f9ee Steve Glendinning 2012-10-26  1133  
bbd9f9ee Steve Glendinning 2012-10-26  1134  		for (i = 0; i < (pdata->wuff_filter_count / 4); i++) {
bbd9f9ee Steve Glendinning 2012-10-26  1135  			ret = smsc95xx_write_reg(dev, WUFF, command[i]);
bbd9f9ee Steve Glendinning 2012-10-26 @1136  			check_warn_return(ret, "Error writing WUFF");
bbd9f9ee Steve Glendinning 2012-10-26  1137  		}
bbd9f9ee Steve Glendinning 2012-10-26  1138  
bbd9f9ee Steve Glendinning 2012-10-26  1139  		for (i = 0; i < (pdata->wuff_filter_count / 4); i++) {

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
