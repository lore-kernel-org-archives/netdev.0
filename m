From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: linux 2.6.32.46 crashes
Date: Tue, 30 Aug 2011 14:56:49 -0600
Message-ID: <4E5D4E91.3070503@canonical.com>
References: <201108302231.47530.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000608010109050209090701"
Cc: Greg KH <greg@kroah.com>, "gregkh@suse.de" <gregkh@suse.de>,
	linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([70.99.223.143]:4447 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756690Ab1H3U5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 16:57:20 -0400
In-Reply-To: <201108302231.47530.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000608010109050209090701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 08/30/2011 02:31 PM, Wolfgang Walter wrote:
> Hello,
>
> I upgraded several machines from 2.6.32.43 to 2.6.32.46 and
> they all crashed when the kernel boots.
>
> I bisected it to the following commit:
>
>
> 35ed3d0fb62804090a3f21a7ce84c538a6ff852f is the first bad commit
> commit 35ed3d0fb62804090a3f21a7ce84c538a6ff852f
> Author: Alexey Dobriyan<adobriyan@gmail.com>
> Date:   Tue Feb 16 09:05:04 2010 +0000
>
>      tunnels: fix netns vs proto registration ordering
>
>      commit d5aa407f59f5b83d2c50ec88f5bf56d40f1f8978 upstream.
>
>      Same stuff as in ip_gre patch: receive hook can be called before netns
>      setup is done, oopsing in net_generic().
>
>      Signed-off-by: Alexey Dobriyan<adobriyan@gmail.com>
>      Signed-off-by: David S. Miller<davem@davemloft.net>
>      Signed-off-by: Greg Kroah-Hartman<gregkh@suse.de>
>
> :040000 040000 6338c45b1372e7e3c5a5ef466dc365cc47a2e152 cde6b92bab403d860cca90e8232cb9c03090fc7e M      net
>
>
> Reverting it on top of 2.6.32.46 fixes the problem for me.
>

<snip>

Wolfgang - see if this patch fixes your problem.

rtg

-- 
Tim Gardner tim.gardner@canonical.com

--------------000608010109050209090701
Content-Type: text/x-patch;
 name="0001-tunnels-fix-netns-vs-proto-registration-ordering-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-tunnels-fix-netns-vs-proto-registration-ordering-fix.pa";
 filename*1="tch"

>From e52d45fe5518e8447b54b440f41d318db146a19e Mon Sep 17 00:00:00 2001
From: Andy Whitcroft <apw@canonical.com>
Date: Tue, 30 Aug 2011 13:44:23 +0100
Subject: [PATCH] tunnels: fix netns vs proto registration ordering -- fix stable backport

BugLink: http://bugs.launchpad.net/bugs/837421

As per Stratos Psomadakis the backport of the upstream commit below is
flawed and introduces crashes when using this ipv6 tunnel type:

  commit a14a3f90745c4831a1437528706b38daa1db4885
  Author: Alexey Dobriyan <adobriyan@gmail.com>
  Date:   Tue Feb 16 09:05:04 2010 +0000

    tunnels: fix netns vs proto registration ordering

Signed-off-by: Andy Whitcroft <apw@canonical.com>
Acked-by: Stefan Bader <stefan.bader@canonical.com>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 net/ipv6/ip6_tunnel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 7fb3e02..53e0d51 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1466,7 +1466,7 @@ static int __init ip6_tunnel_init(void)
 {
 	int  err;
 
-	err = register_pernet_device(&ip6_tnl_net_ops);
+	err = register_pernet_gen_device(&ip6_tnl_net_id, &ip6_tnl_net_ops);
 	if (err < 0)
 		goto out_pernet;
 
-- 
1.7.0.4


--------------000608010109050209090701--
