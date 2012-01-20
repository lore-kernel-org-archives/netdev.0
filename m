From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: l2tp support
Date: Fri, 20 Jan 2012 11:06:04 -0800
Message-ID: <20120120110604.1101991b@nehalam.linuxnetplumber.net>
References: <20111229094214.238a1b8f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50544 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753777Ab2ATTGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 14:06:08 -0500
In-Reply-To: <20111229094214.238a1b8f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Dec 2011 09:42:14 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> I updated the latest iproute2 in git to include support for L2TP.
> It is based on James's code but instead of using libnl, it uses netlink
> directly (like I asked when rejecting the original patch).
> 
> In order to make netlink code in iproute2 cleaner, several libnetlink
> have been updated.
>   * unused junk argument to rtnl_dump_filter and rtnl_talk have
>     been removed.
>   * addattr_xx functions for building attributes added.
>   * rta_getattr_XXX inline functions for the common case of
>     looking at basic type attributes
> 
> This will show up in 3.2 version of iproute2 which is ready and
> waiting for kernel release.

The addition of l2tp broke the common syntax of 'ip l' since it would
match ip l2tp rather than ip link.

Just added the following patch:

commit 5aa08f6bf4107f8aec43c0678466a314dbd0d054
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Fri Jan 20 08:16:02 2012 -0800

    ip: make 'ip l' be 'ip link'
    
    Restore compatiablity for those lazy typists.

diff --git a/ip/ip.c b/ip/ip.c
index 7b4bacb..20dc3b5 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -72,8 +72,8 @@ static const struct cmd {
 	{ "neighbour",	do_ipneigh },
 	{ "ntable",	do_ipntable },
 	{ "ntbl",	do_ipntable },
-	{ "l2tp",	do_ipl2tp },
 	{ "link",	do_iplink },
+	{ "l2tp",	do_ipl2tp },
 	{ "tunnel",	do_iptunnel },
 	{ "tunl",	do_iptunnel },
 	{ "tuntap",	do_iptuntap },
