From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: stmmac: platform: fix default values of the filter bins setting
Date: Tue, 2 Dec 2014 16:41:08 -0700
Message-ID: <CAErSpo4-Kd2WTQHO01Syce4oj_w+Oui6kMcucLZNsWi-v8u4WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: Huacai Chen <chenhc@lemote.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:61236 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933192AbaLBXl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 18:41:29 -0500
Received: by mail-qa0-f51.google.com with SMTP id k15so9753107qaq.10
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 15:41:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like 571dcfde2371 ("stmmac: platform: fix default values of the
filter bins setting") introduced the following error.  Either

  1) "plat_dat" can never be NULL, and the test and associated code
should be removed, or
  2) "plat_dat" may be NULL, and we may now dereference it and cause an oops.

---------- Forwarded message ----------
From:  <scan-admin@coverity.com>
Date: Tue, Dec 2, 2014 at 4:16 PM
Subject: New Defects reported by Coverity Scan for Linux
To: bhelgaas@google.com



Hi,

Please find the latest report on new defect(s) introduced to Linux
found with Coverity Scan.

1 new defect(s) introduced to Linux found with Coverity Scan.
5 defect(s), reported by Coverity Scan earlier, were marked fixed in
the recent build analyzed by Coverity Scan.

New defect(s) Reported-by: Coverity Scan
Showing 1 of 1 defect(s)


** CID 1256529:  Dereference before null check  (REVERSE_INULL)
/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c: 275 in
stmmac_pltfr_probe()


________________________________________________________________________________________________________
*** CID 1256529:  Dereference before null check  (REVERSE_INULL)
/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c: 275 in
stmmac_pltfr_probe()
269             plat_dat->multicast_filter_bins = HASH_TABLE_SIZE;
270
271             /* Set default value for unicast filter entries */
272             plat_dat->unicast_filter_entries = 1;
273
274             if (pdev->dev.of_node) {
>>>     CID 1256529:  Dereference before null check  (REVERSE_INULL)
>>>     Null-checking "plat_dat" suggests that it may be null, but it has already been dereferenced on all paths leading to the check.
275                     if (!plat_dat)
276                             plat_dat = devm_kzalloc(&pdev->dev,
277                                             sizeof(struct
plat_stmmacenet_data),
278                                             GFP_KERNEL);
279                     if (!plat_dat) {
280                             pr_err("%s: ERROR: no memory", __func__);


________________________________________________________________________________________________________
To view the defects in Coverity Scan visit,
http://scan.coverity.com/projects/128?tab=overview

To unsubscribe from the email notification for new defects,
http://scan5.coverity.com/cgi-bin/unsubscribe.py
