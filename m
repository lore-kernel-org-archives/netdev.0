From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [NETFILTER]: x_tables: replace IPv4 dscp match by address
 family independent version
Date: Mon, 25 Sep 2006 09:56:01 +0900 (JST)
Message-ID: <200609250056.k8P0u47W008051@toshiba.co.jp>
References: <200609240002.k8O02wT5010490@hera.kernel.org>
	<1159128158.24527.948.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Mon_Sep_25_09_56_01_2006_571)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yasuyuki.kozakai@toshiba.co.jp,
	kaber@trash.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-tsb.toshiba.co.jp ([202.33.96.40]:43148 "EHLO
	inet-tsb.toshiba.co.jp") by vger.kernel.org with ESMTP
	id S1751735AbWIYA4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 20:56:07 -0400
Received: from tsb-wall.toshiba.co.jp ([133.199.160.134])
	by inet-tsb.toshiba.co.jp  with ESMTP id k8P0u5Aq022857
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 09:56:05 +0900 (JST)
Received: (from root@localhost)
	by tsb-wall.toshiba.co.jp  id k8P0u6wK013414
	for netdev@vger.kernel.org; Mon, 25 Sep 2006 09:56:06 +0900 (JST)
Received: from mx.toshiba.co.jp (localhost [127.0.0.1])
	by ovp1.toshiba.co.jp  with ESMTP id k8P0u4S9010630
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 09:56:04 +0900 (JST)
To: dwmw2@infradead.org
In-Reply-To: <1159128158.24527.948.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----Next_Part(Mon_Sep_25_09_56_01_2006_571)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hello,

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 24 Sep 2006 21:02:38 +0100

> On Sun, 2006-09-24 at 00:02 +0000, Linux Kernel Mailing List wrote:
> > --- a/include/linux/netfilter_ipv4/ipt_dscp.h
> > +++ b/include/linux/netfilter_ipv4/ipt_dscp.h
> > @@ -10,14 +10,12 @@
> >  #ifndef _IPT_DSCP_H
> >  #define _IPT_DSCP_H
> >  
> > -#define IPT_DSCP_MASK  0xfc    /* 11111100 */
> > -#define IPT_DSCP_SHIFT 2
> > -#define IPT_DSCP_MAX   0x3f    /* 00111111 */
> > +#include <linux/netfilter/xt_dscp.h> 
> 
> This causes the following error in 'make headers_check':
> 
> linux/netfilter_ipv4/ipt_DSCP.h requires linux/netfilter/xt_DSCP.h,
> which does not exist in exported headers
> make[4]: *** [ipt_DSCP.h] Error 1
> 
> Please remember to run 'make headers_check' before submitting patches.

Thanks for notice. I'll do that from next time.

David, please apply the attached patch.

-- Yasuyuki Kozakai

----Next_Part(Mon_Sep_25_09_56_01_2006_571)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="dscp.patch"

[NETFILTER]: Add dscp,DSCP headers to header-y

This patch adds xt_dscp.h and xt_DSCP.h to the kernel headers which are
exported via 'make headers_install'. These are necessary for userspace
to add rules using dscp match and DSCP target.

Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>

---
commit 268b6f1e4a605e77eddb606e7c817e6adfa351cf
tree 20e8ef57cb366b5b8a9d773fc1b533b2bf9edaf5
parent 508df253dbefb0385a629370f4244e3db197d3b8
author Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> Mon, 25 Sep 2006 09:16:59 +0900
committer Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> Mon, 25 Sep 2006 09:16:59 +0900

 include/linux/netfilter/Kbuild |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 9a285ce..312bd2f 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -10,6 +10,8 @@ header-y += xt_connmark.h
 header-y += xt_CONNMARK.h
 header-y += xt_conntrack.h
 header-y += xt_dccp.h
+header-y += xt_dscp.h
+header-y += xt_DSCP.h
 header-y += xt_esp.h
 header-y += xt_helper.h
 header-y += xt_length.h

----Next_Part(Mon_Sep_25_09_56_01_2006_571)----
