From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ethtool: RXHASH flag support
Date: Tue, 30 Mar 2010 14:05:19 -0700
Message-ID: <20100330140519.7b45cbb6@nehalam>
References: <20100328154448.701c89ee@nehalam>
	<20100329174727.4654e19c@nehalam>
	<20100329175352.38008e05@nehalam>
	<4BB234DD.9040800@garzik.org>
	<20100330103207.7fc5681a@nehalam>
	<4BB236C9.7080300@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43954 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752051Ab0C3VF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 17:05:29 -0400
In-Reply-To: <4BB236C9.7080300@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 13:37:13 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> On 03/30/2010 01:32 PM, Stephen Hemminger wrote:
> > On Tue, 30 Mar 2010 13:29:01 -0400
> > Jeff Garzik<jeff@garzik.org>  wrote:
> >
> >> By blindly sync'ing the ethtool.h header, ETHTOOL_MAX_NTUPLE_LIST_ENTRY
> >> and its sibling ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY were removed,
> >> breaking the ethtool build.
> >
> > In the patch I moved it to ethtool.c to have local entries.
> >
> > I believe that all cloned headers should only come from the result
> > of kernel "make install_headers".  Not locally different vrsions.
> 
> There is nothing locally different about ethtool-copy.h.
> 
> 	Jeff

diff -u ethtool-copy.h ~/kernel/net-next-2.6/usr/include/linux/ethtool.h
--- ethtool-copy.h	2010-03-30 14:03:45.000000000 -0700
+++ /home/shemminger/kernel/net-next-2.6/usr/include/linux/ethtool.h	2010-03-30 14:04:30.893866057 -0700
@@ -36,7 +36,7 @@
 	__u32	reserved[2];
 };
 
-static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 						__u32 speed)
 {
 
@@ -44,7 +44,7 @@
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static inline __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
+static __inline__ __u32 ethtool_cmd_speed(struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
@@ -424,6 +424,7 @@
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
 
+
 /* CMDs currently supported */
 #define ETHTOOL_GSET		0x00000001 /* Get settings. */
 #define ETHTOOL_SSET		0x00000002 /* Set settings. */
