From: Adam Bernau <adam.r.bernau@gmail.com>
Subject: sunhme duplicate macs
Date: Thu, 18 Jun 2009 14:39:49 +1000
Message-ID: <9983e31f0906172139v3027d453k65e83590d7788fc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:40752 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbZFREjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 00:39:47 -0400
Received: by pxi27 with SMTP id 27so814307pxi.33
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2009 21:39:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been annoyed at the duplicate macs on my Sun qfe card (sunhme
driver) for a while, and was doing some research. Back in Oct 2007
there was a patch on the linux-kernel and netdev mailing lists. At the
time the patch was rejected as the incorrect fix, and it was suggested
that the is_quattro_p function might be the problem by always
returning 0. I noticed that it has the following check at the start of
the function

2867        if (busdev == NULL ||
2868            busdev->vendor != PCI_VENDOR_ID_DEC ||
2869            busdev->device != PCI_DEVICE_ID_DEC_21153)
2870                return 0;

A few lines lower down, it iterates through devices looking for SUN
PCI IDS and increments the count.

2877                if (this_pdev->vendor == PCI_VENDOR_ID_SUN &&
2878                    this_pdev->device == PCI_DEVICE_ID_SUN_HAPPYMEAL)
2879                        n_hmes++;

According to lspci my qfe cards have the vendor ID of Sun and are
happymeals, not DECs. Does this mean that the first checks on lines
2868, 2869 are actually incorrect, which causes the return 0 to be hit
every time - ie a relic or copy/paste problem from another driver.
Alternatively, did DEC make some qfe's, and Sun some others? There is
also another DEC reference on lines 3152,3

    Adam
