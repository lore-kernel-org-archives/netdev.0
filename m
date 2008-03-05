From: David Miller <davem@davemloft.net>
Subject: Re: [patch (for 2.6.25?) 1/2] The kernel gets no IP from some DHCP
 servers
Date: Tue, 04 Mar 2008 17:04:28 -0800 (PST)
Message-ID: <20080304.170428.49329670.davem@davemloft.net>
References: <200803042256.m24MumHJ001353@imap1.linux-foundation.org>
	<20080304162342.65d6340c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	Marcel.Wappler@bridgeco.net, kaber@trash.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42894
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751254AbYCEBEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 20:04:44 -0500
In-Reply-To: <20080304162342.65d6340c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 4 Mar 2008 16:23:42 -0800

> Same patch without the noise comment and extra code.

Much nicer.

The following is what I'll push to Linus.

Thanks.

commit dea75bdfa57f75a7a7ec2961ec28db506c18e5db
Author: Stephen Hemminger <shemminger@linux-foundation.org>
Date:   Tue Mar 4 17:03:49 2008 -0800

    [IPCONFIG]: The kernel gets no IP from some DHCP servers
    
    From: Stephen Hemminger <shemminger@linux-foundation.org>
    
    Based upon a patch by Marcel Wappler:
    
       This patch fixes a DHCP issue of the kernel: some DHCP servers
       (i.e.  in the Linksys WRT54Gv5) are very strict about the contents
       of the DHCPDISCOVER packet they receive from clients.
    
       Table 5 in RFC2131 page 36 requests the fields 'ciaddr' and
       'siaddr' MUST be set to '0'.  These DHCP servers ignore Linux
       kernel's DHCP discovery packets with these two fields set to
       '255.255.255.255' (in contrast to popular DHCP clients, such as
       'dhclient' or 'udhcpc').  This leads to a not booting system.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 10013cc..5dd9385 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -753,9 +753,9 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
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
