From: Stephen Hemminger <stephen@networkplumber.org>
Subject: new coverity defect in ipv6 route
Date: Wed, 28 Oct 2015 09:43:30 +0900
Message-ID: <20151028094330.1acb02db@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36178 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbbJ1Anw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 20:43:52 -0400
Received: by pacfv9 with SMTP id fv9so248555630pac.3
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 17:43:52 -0700 (PDT)
Received: from samsung9 ([144.49.132.22])
        by smtp.gmail.com with ESMTPSA id g12sm42002233pat.36.2015.10.27.17.43.50
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 17:43:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 27 Oct 2015 08:43:53 -0700
From: scan-admin@coverity.com
To: stephen@networkplumber.org
Subject: New Defects reported by Coverity Scan for Linux



Hi,

Please find the latest report on new defect(s) introduced to Linux found with Coverity Scan.

2 new defect(s) introduced to Linux found with Coverity Scan.
12 defect(s), reported by Coverity Scan earlier, were marked fixed in the recent build analyzed by Coverity Scan.

New defect(s) Reported-by: Coverity Scan
Showing 2 of 2 defect(s)


** CID 1328821:  Memory - corruptions  (ARRAY_VS_SINGLETON)
/net/ipv6/route.c: 320 in rt6_info_init()


________________________________________________________________________________________________________
*** CID 1328821:  Memory - corruptions  (ARRAY_VS_SINGLETON)
/net/ipv6/route.c: 320 in rt6_info_init()
314     #endif
315     
316     static void rt6_info_init(struct rt6_info *rt)
317     {
318     	struct dst_entry *dst = &rt->dst;
319     
>>>     CID 1328821:  Memory - corruptions  (ARRAY_VS_SINGLETON)
>>>     Using "dst" as an array.  This might corrupt or misinterpret adjacent memory locations.
320     	memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
321     	INIT_LIST_HEAD(&rt->rt6i_siblings);
322     	INIT_LIST_HEAD(&rt->rt6i_uncached);
323     }
324     
325     /* allocate dst with ip6_dst_ops */

** CID 1328822:  Incorrect expression  (UNUSED_VALUE)
/drivers/net/wireless/rtlwifi/rtl8821ae/sw.c: 170 in rtl8821ae_init_sw_vars()


________________________________________________________________________________________________________
*** CID 1328822:  Incorrect expression  (UNUSED_VALUE)
/drivers/net/wireless/rtlwifi/rtl8821ae/sw.c: 170 in rtl8821ae_init_sw_vars()
164     	/* for debug level */
165     	rtlpriv->dbg.global_debuglevel = rtlpriv->cfg->mod_params->debug;
166     	/* for LPS & IPS */
167     	rtlpriv->psc.inactiveps = rtlpriv->cfg->mod_params->inactiveps;
168     	rtlpriv->psc.swctrl_lps = rtlpriv->cfg->mod_params->swctrl_lps;
169     	rtlpriv->psc.fwctrl_lps = rtlpriv->cfg->mod_params->fwctrl_lps;
>>>     CID 1328822:  Incorrect expression  (UNUSED_VALUE)
>>>     Assigning value from "rtlpriv->cfg->mod_params->msi_support" to "rtlpci->msi_support" here, but that stored value is overwritten before it can be used.
170     	rtlpci->msi_support = rtlpriv->cfg->mod_params->msi_support;
171     	rtlpci->msi_support = rtlpriv->cfg->mod_params->int_clear;
172     	if (rtlpriv->cfg->mod_params->disable_watchdog)
173     		pr_info("watchdog disabled\n");
174     	rtlpriv->psc.reg_fwctrl_lps = 3;
175     	rtlpriv->psc.reg_max_lps_awakeintvl = 5;


________________________________________________________________________________________________________
To view the defects in Coverity Scan visit, https://scan.coverity.com/projects/linux?tab=overview

To manage Coverity Scan email notifications for "stephen@networkplumber.org", click https://scan.coverity.com/subscriptions/edit?email=stephen%40networkplumber.org&token=41b352b884ef3fc73426635eebc294c3
