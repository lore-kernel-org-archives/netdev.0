From: Donatas Abraitis <donatas.abraitis@gmail.com>
Subject: [PATCH -stable 3.10,backport] net: ipv6: drop non loopback packets
 claiming to originate from ::1
Date: Tue, 25 Apr 2017 22:56:07 +0300
Message-ID: <CAPF+HwXpCsn2DvwKJtiJKF_zHQMmUxfoMOrPPGFUdW9on95wJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35237 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1433170AbdDYT4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 15:56:13 -0400
Received: by mail-it0-f44.google.com with SMTP id 70so25783661ita.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 12:56:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0aa8c13eb512823bc4d60397d666a6b6260bb965 upstream.

We lack a saddr check for ::1. This causes security issues e.g. with acls
permitting connections from ::1 because of assumption that these originate
from local machine.

Assuming a source address of ::1 is local seems reasonable.
RFC4291 doesn't allow such a source address either, so drop such packets.

As IPv6 is getting faster pace, this patch should be included in older
kernels, for instance, 3.10 (RHEL7 family). It could be solved with
netfilter, but why do not apply this trivial patch to work as
expected?

-- 
Donatas
