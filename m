From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/3] nfp: extend firmware request logic
Date: Wed, 26 Jul 2017 11:09:45 -0700
Message-ID: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33867 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751103AbdGZSMb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:12:31 -0400
Received: by mail-pg0-f54.google.com with SMTP id 123so87445326pgj.1
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 11:12:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

We have been pondering for some time how to support loading different
application firmwares onto NFP.  We want to support both users selecting
one of the firmware images provided by Netronome (which are optimized
for different use cases each) as well as firmware images created  by 
users themselves or other companies.

In the end we decided to go with the simplest solution - depending on
the right firmware image being placed in /lib/firmware.  This vastly
simplifies driver logic and also doesn't require any new API.

Different NICs on one system may want to run different applications
therefore we first try to load firmware specific to the device (by 
serial number of PCI slot) and if not present try the device model
based name we have been using so far.


Jakub Kicinski (3):
  nfp: remove the probe deferral when FW not present
  nfp: look for firmware image by device serial number and PCI name
  nfp: only use direct firmware requests

 drivers/net/ethernet/netronome/nfp/nfp_main.c     | 48 ++++++++++++++++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c |  2 +-
 2 files changed, 39 insertions(+), 11 deletions(-)

-- 
2.11.0
