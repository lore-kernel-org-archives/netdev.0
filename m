From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: GREv4 ipv6 is broken for UDP stream on 3.9
Date: Wed, 29 May 2013 11:16:21 +0300
Message-ID: <CAM8tLiOQq2a_Z=F_V5A2saPN+JfwN7Ey29r+UmUK_f9oYF5vCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pravin B Shelar <pshelar@nicira.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:59965 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965050Ab3E2IQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:16:24 -0400
Received: by mail-bk0-f53.google.com with SMTP id mx10so208356bkb.12
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 01:16:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

since 3.9-rc1 i see that rx side drops all data packets for:

netperf -6 -t UDP_STREAM -H fe80::5efe:c0a8:630c%gre_7 -l 1

when gre_7 is:

13: gre_7: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN
    link/gre 192.168.99.29 peer 192.168.99.12

The packets just gets corrupted.

This bisected to:
commit 68c331631143f5f039baac99a650e0b9e1ea02b6
Author: Pravin B Shelar <pshelar@nicira.com>
Date:   Thu Feb 14 14:02:41 2013 +0000

    v4 GRE: Add TCP segmentation offload for GRE

Looks like gre_gso_segment build wrong segments for GSO flow.
