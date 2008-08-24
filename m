From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [bisected] Weird sysctl regression
Date: Sun, 24 Aug 2008 12:54:24 +0100
Message-ID: <20080824115424.GP28946@ZenIV.linux.org.uk>
References: <87fxoyal9j.fsf@natisbad.org> <20080823084936.GK28946@ZenIV.linux.org.uk> <87wsi7en1m.fsf@natisbad.org> <20080823170248.GL28946@ZenIV.linux.org.uk> <87ljynd582.fsf@natisbad.org> <20080823181651.GM28946@ZenIV.linux.org.uk> <87od3jo2vn.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39738 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128AbYHXLy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 07:54:26 -0400
Content-Disposition: inline
In-Reply-To: <87od3jo2vn.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 11:09:00PM +0200, Arnaud Ebalard wrote:
> Hi,
> 
> Al Viro <viro@ZenIV.linux.org.uk> writes:
> 
> > On Sat, Aug 23, 2008 at 07:13:49PM +0200, Arnaud Ebalard wrote:
> >
> >> I already tested 26.27-rc4 and even net-next-2.6 (recently released one
> >> based on rc4 with some bug fixes). Problem is still here.
> >
> > Just to make sure: that's rc4 without any additional patches?
> 
> Sorry for the delay. Yes, no additional patches in both cases:
> 
> - stock 2.6.27-rc4 from kernel.org
> - freshly cloned net-next-2.6 after David's announcement

Gyah...  Dumb braino on my part.  That sucker should've gone into the
global class, not the rotable stuff.  See if that helps...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index e6dfaea..587f8f6 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -156,7 +156,7 @@ static struct ctl_table_header *ip6_base;
 int ipv6_static_sysctl_register(void)
 {
 	static struct ctl_table empty[1];
-	ip6_base = register_net_sysctl_rotable(net_ipv6_ctl_path, empty);
+	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, empty);
 	if (ip6_base == NULL)
 		return -ENOMEM;
 	return 0;
