From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next repost 0/3] tc: flower: support masked ICMP code and type match
Date: Thu,  9 Feb 2017 14:48:58 +0100
Message-ID: <1486648141-22955-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35410 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdBIN4z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:56:55 -0500
Received: by mail-wm0-f54.google.com with SMTP id v186so81525268wmd.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:56:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this short series allows the tc tool to configure masked matches on the
ICMP code and type. Unmasked matches are already supported by the tool.

This does not depend on any kernel changes as support for both masked and
unmasked matches were added to the kernel at the same time.

Sample usage:

tc qdisc add dev eth0 ingress
tc filter add dev eth0 protocol ipv6 parent ffff: flower \
        indev eth0 ip_proto icmpv6 type 128/240 code 0 action drop

Reposting after breaking out of a larger patchset.

Simon Horman (3):
  tc: flower: provide generic masked u8 parser helper
  tc: flower: provide generic masked u8 print helper
  tc: flower: support masked ICMP code and type match

 man/man8/tc-flower.8 |  16 ++++--
 tc/f_flower.c        | 158 ++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 119 insertions(+), 55 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
