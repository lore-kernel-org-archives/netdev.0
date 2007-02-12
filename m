From: Amit Kale <amitkale@netxen.com>
Subject: Re: NetXen driver name
Date: Mon, 12 Feb 2007 14:48:50 +0530
Message-ID: <200702121448.50399.amitkale@netxen.com>
References: <200702082152.19772.amitkale@netxen.com> <200702120912.56487.ak@suse.de> <20070212082950.GD4095@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:20030 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964802AbXBLJSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 04:18:41 -0500
In-Reply-To: <20070212082950.GD4095@ftp.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 February 2007 13:59, Al Viro wrote:
> On Mon, Feb 12, 2007 at 09:12:56AM +0100, Andi Kleen wrote:
> > On Monday 12 February 2007 09:03, Amit Kale wrote:
> > > The already released kernel contains a broken driver.  It broke due to
> > > some code rearrangement changes someone submitted to fix sparse
> > > warnings.
>
> s/sparse warnings/breakage on big-endian boxen/, actually.  This stuff
> was sent to netdev tree and sat there for a while.  Pity if some breakage
> occured and went unnoticed; could you give more details?

We were in middle of other changes last week. 

Here it is.  This is FYI only. We'll send a set of patches with this change as 
well as some other in a short time.

diff -Narup not_working/netxen/netxen_nic.h got_working/netxen/netxen_nic.h
--- not_working/netxen/netxen_nic.h	2007-02-08 23:20:34.468721000 -0800
+++ got_working/netxen/netxen_nic.h	2007-02-08 23:19:44.526769000 -0800
@@ -252,7 +252,7 @@ typedef u32 netxen_ctx_msg;
 #define netxen_set_msg_ctxid(config_word, val)	\
 	((config_word) &= ~(0x3ff<<18), (config_word) |= (val & 0x3ff) << 18)
 #define netxen_set_msg_opcode(config_word, val)	\
-	((config_word) &= ~(0xf<<24), (config_word) |= (val & 0xf) << 24)
+	((config_word) &= ~(0xf<<28), (config_word) |= (val & 0xf) << 28)
 
 struct netxen_rcv_context {
 	__le64 rcv_ring_addr;
@@ -309,8 +309,8 @@ struct netxen_ring_ctx {
 	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xff), \
 	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32((val) & 0xff))
 #define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= cpu_to_le32(0xff), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 24))
+	((cmd_desc)->num_of_buffers_total_length &= cpu_to_le32(0xffffff), \
+	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 8))
 
 #define netxen_get_cmd_desc_opcode(cmd_desc)	\
 	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003F)
