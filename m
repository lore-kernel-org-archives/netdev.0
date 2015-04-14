From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v4 0/6] mpls: Behaviour-changing improvements
Date: Tue, 14 Apr 2015 23:44:57 +0100
Message-ID: <1429051503-31287-1-git-send-email-rshearma@brocade.com>
References: <1427739356-28113-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54587 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932122AbbDNWqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 18:46:35 -0400
In-Reply-To: <1427739356-28113-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V4:
  - Split out per-device enabling of packet input into two
    patches. The first for creating the struct mpls_dev state per
    interface and the second actually implementing the enable config.
  - Reworked unlabeled patch to use new rtnetlink attribute,
    RTA_MPLS_PAYLOAD_TYPE instead of a special label value.
  - In payload type association patch, use success local variable
    instead of multiple return statements.
  - New patch to disallow the use of imp-null as an outgoing label.
V3:
  - Dropped PHP comment patch to avoid holding up the rest of the
    changes due to quibbling on nomenclature.
  - Corrected reference to RFC 3031 in commit message of patch
    2. Added reference to RFC 3031 s4.1.5 for PHP behaviour.
  - s/forwarding/input/ in patch 3.
  - Made MPT_IPV4 and MPT_IPV6 equal to 4 and 6 respectively in patch
    4, eliminating a switch on the version number as suggested by
    review comments. Added back references to RFCs, but moved them to
    mpls_payload_type enum declaration.
V2:
  - Updated to reference the correct RFC in the first patch.

This series consists of several small changes to make it easier to
understand the code, along with security and RFC-compliance
changes. These are important to consider before userspace begins
relying on the previous behaviour.

Robert Shearman (6):
  mpls: Use definition for reserved label checks
  mpls: Per-device MPLS state
  mpls: Per-device enabling of packet input
  mpls: Allow payload type to be associated with label routes
  mpls: Differentiate implicit-null and unlabeled neighbours
  mpls: Prevent use of implicit NULL label as outgoing label

 Documentation/networking/mpls-sysctl.txt |   9 ++
 include/linux/netdevice.h                |   4 +
 include/uapi/linux/mpls.h                |  16 ++
 include/uapi/linux/rtnetlink.h           |   1 +
 net/mpls/af_mpls.c                       | 242 ++++++++++++++++++++++++++-----
 net/mpls/internal.h                      |   7 +
 6 files changed, 239 insertions(+), 40 deletions(-)

-- 
2.1.4
