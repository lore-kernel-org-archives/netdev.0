From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: bug in "PCI: Support INTx masking on ConnectX-4 with firmware x.14.1100+"?
Date: Mon, 10 Jul 2017 18:49:07 +0200
Message-ID: <CAK1hOcP-+=8SMi8z6zxwqYYcJtSnGHv36Db6fj3Zenux0ViN4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Noa Osherovich <noaos@mellanox.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:36221 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754222AbdGJQta (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 12:49:30 -0400
Received: by mail-lf0-f46.google.com with SMTP id h22so66721923lfk.3
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 09:49:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+       /* Reading from resource space should be 32b aligned */
+       fw_maj_min = ioread32be(fw_ver);
+       fw_sub_min = ioread32be(fw_ver + 1);
+       fw_major = fw_maj_min & 0xffff;
+       fw_minor = fw_maj_min >> 16;
+       fw_subminor = fw_sub_min & 0xffff;

Maybe second read should be ioread32be(fw_ver + 4)?
