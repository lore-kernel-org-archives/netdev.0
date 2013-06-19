From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next 1/8] i40e: main driver core
Date: Wed, 19 Jun 2013 11:55:42 -0700
Message-ID: <20130619115542.767eaee4@samsung-9>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:53250 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934694Ab3FSSzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:55:47 -0400
Received: by mail-pa0-f42.google.com with SMTP id rl6so5456843pac.29
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:55:46 -0700 (PDT)
In-Reply-To: <1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Jun 2013 20:55:15 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> +
> +char i40e_driver_name[] = "i40e";

Obviously const

+/* Helper macros for reading the stats registers
+ *
+ * Since the device stats are not reset at PFReset, they likely will not
+ * be zeroed when the driver starts.  We'll save the first values read
+ * and use them as offsets to be subtracted from the raw values in order
+ * to report stats that count from zero.
+ */
+#define I40E_STAT_UPDATE48(hireg, loreg, offset_loaded, offset, stat)     \
+do {                                                                      \
+	u64 new_data;                                                     \
+	new_data = rd64(hw, (loreg));                                     \
+	if (!(offset_loaded))                                             \
+		(offset) = new_data;                                      \
+	if (likely(new_data >= (offset)))                                 \
+		(stat) = new_data - (offset);                             \
+	else                                                              \
+		(stat) = (new_data + ((u64)1 << 48)) - (offset);          \
+	(stat) &= 0xFFFFFFFFFFFFULL;                                      \
+} while (0)

Macro's suck, this could just as well be a function
or maybe a macro that calls function (and go ahead and do string manipulation)
