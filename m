From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [wireless-next:for-davem 123/299] net/ipv4/ip_gre.c:222:29: sparse:
 restricted __be16 degrades to integer
Date: Sat, 29 Sep 2012 09:12:10 +0800
Message-ID: <20120929011210.GA10053@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: stephen hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40298 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964950Ab2I2BMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 21:12:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi stephen,

FYI, there are new sparse warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git for-davem
head:   c487606f835a93a725bac1aefd536be98f22474d
commit: d208328765a0ab425e36b5b828285f3337a85451 [123/299] gre: fix handling of key 0

+ net/ipv4/ip_gre.c:222:29: sparse: restricted __be16 degrades to integer
  net/ipv4/ip_gre.c:227:34: sparse: restricted __be16 degrades to integer
+ net/ipv4/ip_gre.c:562:33: sparse: incorrect type in argument 4 (different base types)
  net/ipv4/ip_gre.c:562:33:    expected unsigned int [unsigned] [usertype] flags
  net/ipv4/ip_gre.c:562:33:    got restricted __be16 [assigned] [usertype] flags
  net/ipv4/ip_gre.c:669:62: sparse: incorrect type in argument 4 (different base types)
  net/ipv4/ip_gre.c:669:62:    expected unsigned int [unsigned] [usertype] flags
  net/ipv4/ip_gre.c:669:62:    got restricted __be16 [assigned] [usertype] flags

vim +222 net/ipv4/ip_gre.c

d2083287 (stephen hemminger 2012-09-24  217) /* Does key in tunnel parameters match packet */
d2083287 (stephen hemminger 2012-09-24  218) static bool ipgre_key_match(const struct ip_tunnel_parm *p,
d2083287 (stephen hemminger 2012-09-24  219) 			    __u32 flags, __be32 key)
d2083287 (stephen hemminger 2012-09-24  220) {
d2083287 (stephen hemminger 2012-09-24  221) 	if (p->i_flags & GRE_KEY) {
d2083287 (stephen hemminger 2012-09-24 @222) 		if (flags & GRE_KEY)
d2083287 (stephen hemminger 2012-09-24  223) 			return key == p->i_key;
d2083287 (stephen hemminger 2012-09-24  224) 		else
d2083287 (stephen hemminger 2012-09-24  225) 			return false;	/* key expected, none present */
d2083287 (stephen hemminger 2012-09-24  226) 	} else
d2083287 (stephen hemminger 2012-09-24  227) 		return !(flags & GRE_KEY);
d2083287 (stephen hemminger 2012-09-24  228) }
d2083287 (stephen hemminger 2012-09-24  229) 
^1da177e (Linus Torvalds    2005-04-16  230) /* Given src, dst and key, find appropriate for input tunnel. */

---
0-DAY kernel build testing backend         Open Source Technology Centre
Fengguang Wu, Yuanhan Liu                              Intel Corporation
