From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 master 0/4] pedit: Introduce IPv6 support + some minor fixes
Date: Sun, 14 May 2017 11:17:42 +0300
Message-ID: <20170514081746.9010-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36619 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750882AbdENIRq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 04:17:46 -0400
Received: by mail-wr0-f194.google.com with SMTP id v42so11188789wrc.3
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 01:17:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduces pedit IPv6 support.
Almost all IPv6 header fields are editable now (src, dst, flow_lbl,
payload_len, next_hdr and hoplimit).
The patch uses the new extended pedit netlink and will fail the operation if
kernel has no support or user didn't use the 'ex' keyword.
In addition to this patch, 3 more patches fix some minor UI issues:
- some typo's
- 'retain' can't be used with fields > 32 bits. It will make unexpected things
	when used in such fields. Fixing this limitiation requires some changes (in
	tc user space only) that are out of the scope of this patchset. So I added a
	patch to prevent the user from using retain on those fields.


Thanks,
Amir	

Amir Vadai (4):
  pedit: Fix a typo in warning
  pedit: Do not allow using retain for too big fields
  pedit: Check for extended capability in protocol parser
  pedit: Introduce ipv6 support

 man/man8/tc-pedit.8 | 33 ++++++++++++++++++-
 tc/Makefile         |  1 +
 tc/m_pedit.c        | 51 ++++++++++++++++++++++++++++--
 tc/p_eth.c          |  3 ++
 tc/p_ip.c           | 17 +---------
 tc/p_ip6.c          | 91 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 tc/p_udp.c          |  3 ++
 7 files changed, 179 insertions(+), 20 deletions(-)
 create mode 100644 tc/p_ip6.c

-- 
2.12.2
