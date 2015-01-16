From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next 0/5] bonding: various 802.3ad fixes
Date: Fri, 16 Jan 2015 10:57:23 -0500
Message-ID: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:42797 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbAPP5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 10:57:41 -0500
Received: by mail-qg0-f52.google.com with SMTP id i50so16825937qgf.11
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 07:57:40 -0800 (PST)
Received: from debian-devel.rtplab.test (rrcs-24-171-185-114.midsouth.biz.rr.com. [24.171.185.114])
        by mx.google.com with ESMTPSA id y95sm4475377qgy.14.2015.01.16.07.57.40
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 07:57:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a forward porting of patches we (Cumulus) are shipping
in our 3.2 series kernels. These fixes attempt to make 802.3ad bonding mode
more predictable in certian state machine transtions in addition to enhancing
802.3ad bond carrier determination based on acutal number of peered ports plus
if the bond has an active aggregrator. Specific notes are contained within each
patch.

For this patch series there are no userspace facing changes, a diff between
the modinfo output showed no difference. However, there are behavioral
facing changes, primarily in the bond carrier state. Please make sure to
review carefully.

Jonathan Toppins (1):
  bonding: cleanup and remove dead code

Satish Ashok (1):
  bonding: fix LACP PDU not sent on slave port sometimes

Scott Feldman (1):
  bonding: keep bond interface carrier off until at least one active
    member

Wilson Kok (2):
  bonding: fix bond_open() don't always set slave active flag
  bonding: fix incorrect lacp mux state when agg not active

 drivers/net/bonding/bond_3ad.c     |   73 ++++++++++++++++++++++++++++--------
 drivers/net/bonding/bond_main.c    |    6 +--
 drivers/net/bonding/bond_options.c |    1 +
 include/net/bond_3ad.h             |    1 -
 include/net/bonding.h              |    1 +
 5 files changed, 62 insertions(+), 20 deletions(-)

-- 
1.7.10.4
