From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH 2.6.20] ixgb: Use ARRAY_SIZE macro when appropriate
Date: Tue, 6 Feb 2007 12:00:25 +0200
Message-ID: <20070206100025.GA14903@Ahmed>
References: <20070205165429.GD3896@Ahmed> <20070205165933.GL3896@Ahmed> <20070205201804.GC11055@martell.zuzino.mipt.ru> <45C7941E.2050305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>, jeffrey.t.kirsher@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:10008 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbXBFKAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 05:00:37 -0500
Received: by nf-out-0910.google.com with SMTP id o25so133155nfa
        for <netdev@vger.kernel.org>; Tue, 06 Feb 2007 02:00:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <45C7941E.2050305@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 12:31:26PM -0800, Auke Kok wrote:
> Alexey Dobriyan wrote:
> >On Mon, Feb 05, 2007 at 06:59:33PM +0200, Ahmed S. Darwish wrote:
> >>A patch to use ARRAY_SIZE macro already defined in kernel.h.
> >
> >Remove it and use ARRAY_SIZE instead.
> >
> >>--- a/drivers/net/ixgb/ixgb_param.c
> >>+++ b/drivers/net/ixgb/ixgb_param.c
> >>@@ -245,7 +245,7 @@ ixgb_validate_option(int *value, struct ixgb_option 
> >>*opt)
> >> 	return -1;
> >> }
> >> 
> >>-#define LIST_LEN(l) (sizeof(l) / sizeof(l[0]))
> >>+#define LIST_LEN(l) ARRAY_SIZE(l)
> 
> yes, well spotted. Please change line 338 in this file to read:
> 
>      .arg  = { .l = { .nr = ARRAY_SIZE(fc_list),
> 
> instead, so you can remove the LIST_LEN macro completely.
 
Thanks, Here's the new patch.

Use ARRAY_SIZE macro when appropriate.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index b27442a..c38ce73 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -245,8 +245,6 @@ ixgb_validate_option(int *value, struct ixgb_option *opt)
 	return -1;
 }
 
-#define LIST_LEN(l) (sizeof(l) / sizeof(l[0]))
-
 /**
  * ixgb_check_options - Range Checking for Command Line Parameters
  * @adapter: board private structure
@@ -335,7 +333,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
 			.def  = ixgb_fc_tx_pause,
-			.arg  = { .l = { .nr = LIST_LEN(fc_list),
+			.arg  = { .l = { .nr = ARRAY_SIZE(fc_list),
 					 .p = fc_list }}
 		};


-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
