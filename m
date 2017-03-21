From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Subject: [PATCH v3 0/2] fjes: Do not load fjes driver
Date: Tue, 21 Mar 2017 11:28:02 -0400
Message-ID: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, izumi.taku@jp.fujitsu.com,
        yasu.isimatu@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35765 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755420AbdCUPfC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 11:35:02 -0400
Received: by mail-qk0-f194.google.com with SMTP id o135so22568038qke.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 08:35:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fjes driver is used only by FUJITSU servers and almost of all
servers in the world never use it. But currently if ACPI PNP0C02
is defined in the ACPI table, the following message is always shown:

 "FUJITSU Extended Socket Network Device Driver - version 1.2
  - Copyright (c) 2015 FUJITSU LIMITED"

The message makes users confused because there is no reason that
the message is shown in other vendor servers.

To avoid the confusion, the patch adds several checks.

v3:
  - Rebase on latest net tree.
  - Add _STA method check to avoid loading fjes driver.

v2:
  - Order local variable declarations from longest to shortest line

Yasuaki Ishimatsu(2):
  fjes: Do not load fjes driver if system does not have extended socket device.
  fjes: Do not load fjes driver if extended socket device is not power on.

 drivers/net/fjes/fjes_main.c | 76 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 71 insertions(+), 5 deletions(-)
