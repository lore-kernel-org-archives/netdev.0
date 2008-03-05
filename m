From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch (for 2.6.25?) 1/2] The kernel gets no IP from some DHCP
 servers
Date: Tue, 4 Mar 2008 16:23:42 -0800
Message-ID: <20080304162342.65d6340c@extreme>
References: <200803042256.m24MumHJ001353@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, Marcel.Wappler@bridgeco.net,
	kaber@trash.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39237 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757308AbYCEAY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 19:24:27 -0500
In-Reply-To: <200803042256.m24MumHJ001353@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Mar 2008 14:56:48 -0800
akpm@linux-foundation.org wrote:

> From: "Wappler Marcel" <Marcel.Wappler@bridgeco.net>
> 
> This patch fixes a DHCP issue of the kernel: some DHCP servers (i.e.  in the
> Linksys WRT54Gv5) are very strict about the contents of the DHCPDISCOVER
> packet they receive from clients.
> 
> Table 5 in RFC2131 page 36 requests the fields 'ciaddr' and 'siaddr' MUST be
> set to '0'.  These DHCP servers ignore Linux kernel's DHCP discovery packets
> with these two fields set to '255.255.255.255' (in contrast to popular DHCP
> clients, such as 'dhclient' or 'udhcpc').  This leads to a not booting system.
> 
> I tested this on a ARM embedded device mounting rootfs over NFS obtaining its
> IP from a Linksys WRT54Gv5 Router running VxWorks and a PC based Server
> running a Linux.  Changing the two fields to '0.0.0.0' worked.
> 
> Cc: Stephen Hemminger <shemminger@osdl.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Same patch without the noise comment and extra code.

--- a/net/ipv4/ipconfig.c	2008-03-04 16:20:10.000000000 -0800
+++ b/net/ipv4/ipconfig.c	2008-03-04 16:22:49.000000000 -0800
@@ -753,9 +753,9 @@ static void __init ic_bootp_send_if(stru
 		printk("Unknown ARP type 0x%04x for device %s\n", dev->type, dev->name);
 		b->htype = dev->type; /* can cause undefined behavior */
 	}
+
+	/* server_ip and your_ip address are both already zero per RFC2131 */
 	b->hlen = dev->addr_len;
-	b->your_ip = NONE;
-	b->server_ip = NONE;
 	memcpy(b->hw_addr, dev->dev_addr, dev->addr_len);
 	b->secs = htons(jiffies_diff / HZ);
 	b->xid = d->xid;
