From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Subject: [PATCH net 0/3] fix layer calculation and flow dissector use
Date: Fri, 25 Aug 2017 19:31:00 +0200
Message-ID: <1503682263-17858-1-git-send-email-pieter.jansenvanvuuren@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        simon.horman@netronome.com, jakub.kicinski@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37153 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756096AbdHYRbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 13:31:11 -0400
Received: by mail-wm0-f43.google.com with SMTP id b189so3451496wmd.0
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 10:31:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Previously when calculating the supported key layers MPLS, IPv4/6
TTL and TOS were not considered. Formerly flow dissectors were referenced
without first checking that they are in use and correctly populated by TC.
Additionally this patch set fixes the incorrect use of mask field for vlan
matching.

Pieter Jansen van Vuuren (3):
  nfp: fix unchecked flow dissector use
  nfp: fix supported key layers calculation
  nfp: remove incorrect mask check for vlan matching

 drivers/net/ethernet/netronome/nfp/flower/match.c  | 139 +++++++++++----------
 .../net/ethernet/netronome/nfp/flower/offload.c    |  60 ++++++---
 2 files changed, 113 insertions(+), 86 deletions(-)

-- 
2.7.4
