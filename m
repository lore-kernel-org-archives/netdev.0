From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] if: restore token ring ARP type to header
Date: Tue, 22 May 2012 22:28:28 -0400
Message-ID: <CAP=VYLqMGeFvy8O_zLi+sEP0t6p5M8f_x7d0g1XGkLHdVUVzUg@mail.gmail.com>
References: <20120522140105.284c28cd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:32894 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751035Ab2EWC3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 22:29:00 -0400
Received: by lahd3 with SMTP id d3so4774322lah.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 19:28:59 -0700 (PDT)
In-Reply-To: <20120522140105.284c28cd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 22, 2012 at 5:01 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Recent removal of Token Ring breaks the build of iproute2.
>
> Even though Token Ring support is gone from the kernel, it is worth
> keeping the the definition of the TR ARP type to avoid breaking
> userspace programs that use this file.

Thanks Stephen,  I was trying to force errors in kernel builds by
doing these kinds of define changes while doing my delete tests.

But I was not doing userspace builds, however....

Looking back at the changes I've made, the only thing similar that
I can see is the ipx.h changes:

diff --git a/include/linux/ipx.h b/include/linux/ipx.h
index 3d48014..8f02439 100644
--- a/include/linux/ipx.h
+++ b/include/linux/ipx.h
@@ -38,7 +38,7 @@ struct ipx_interface_definition {
 #define IPX_FRAME_8022		2
 #define IPX_FRAME_ETHERII	3
 #define IPX_FRAME_8023		4
-#define IPX_FRAME_TR_8022       5 /* obsolete */
+/* obsolete token ring was	5 */
 	unsigned char ipx_special;
 #define IPX_SPECIAL_NONE	0
 #define IPX_PRIMARY		1

Please let me/netdev know if the above also happens to trigger any
sort of userspace fallout, and we'll fix it up ASAP.

Thanks,
Paul.
