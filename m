From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v2 0/4] Add support for QSFP+/QSFP28 Diagnostics and 25G/50G/100G port speeds
Date: Sun, 26 Jun 2016 12:45:03 -0700
Message-ID: <1466970307-2411-1-git-send-email-vidya@cumulusnetworks.com>
Cc: bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	dustin@cumulusnetworks.com
To: ben@decadent.org.uk, netdev@vger.kernel.org, bwh@kernel.org,
	davem@davemloft.net, decot@googlers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33967 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbcFZTpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 15:45:11 -0400
Received: by mail-pa0-f54.google.com with SMTP id bz2so52194031pad.1
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2016 12:45:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This patch series provides following support
a) Reorganized fields based out of SFF-8024 fields i.e. Identifier/
   Encoding/Connector types which are common across SFP/SFP+ (SFF-8472)
   and QSFP+/QSFP28 (SFF-8436/SFF-8636) modules into sff-common files.
b) Support for diagnostics information for QSFP Plus/QSFP28 modules
   based on SFF-8436/SFF-8636
c) Supporting 25G/50G/100G speeds in supported/advertising fields
d) Tested across various QSFP+/QSFP28 Copper/Optical modules

Standards for QSFP+/QSFP28
a) QSFP+/QSFP28 - SFF 8636 Rev 2.7 dated January 26,2016
b) SFF-8024 Rev 4.0 dated May 31, 2016

v2: 
  Included support for 25G/50G/100G speeds in supported/
  advertised speed modes
  Review comments from Ben Hutchings:
    Split the sff-8024 reorganzing patch and QSFP+/QSFP28
    patch
    Fixed all checkpatch warnings (except couple of over 80 character)

v1:
  Support for SFF-8636 Rev 2.7
  Review comments from Ben Hutchings:
   Updating copyright holders information for QSFP
   Reusing the common functions and macros across sfpid and qsfp


Vidya Sagar Ravipati (4):
  ethtool-copy.h:sync with net
  ethtool:Reorganizing  SFF-8024 fields for SFP/QSFP
  ethtool:QSFP Plus/QSFP28 Diagnostics Information Support
  ethtool: Enhancing link mode bits to support 25G/50G/100G

 Makefile.am    |   2 +-
 ethtool-copy.h |  17 +-
 ethtool.c      |  32 +++
 internal.h     |   3 +
 qsfp.c         | 876 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 qsfp.h         | 595 +++++++++++++++++++++++++++++++++++++++
 sff-common.c   | 256 +++++++++++++++++
 sff-common.h   | 156 ++++++++++
 sfpdiag.c      |   6 -
 sfpid.c        | 103 +------
 10 files changed, 1936 insertions(+), 110 deletions(-)
 create mode 100644 qsfp.c
 create mode 100644 qsfp.h
 create mode 100644 sff-common.c
 create mode 100644 sff-common.h

-- 
2.1.4
