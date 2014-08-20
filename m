From: Ahmed Tamrawi <ahmedtamrawi@gmail.com>
Subject: Possible dangling mutex_lock in function (rfcomm_tty_open) in file(linux3.3/net/bluetooth/rfcomm/tty.c)
Date: Wed, 20 Aug 2014 11:37:37 -0500
Message-ID: <CAFZT-jJuPPK_EQbv-mJ8Dm9nXBJhfViuxvedAK-agJB2GF1Oaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:35178 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbaHTQhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 12:37:38 -0400
Received: by mail-vc0-f175.google.com with SMTP id ik5so9316451vcb.20
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2014 09:37:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug Report Filed: https://bugzilla.kernel.org/show_bug.cgi?id=82881
Linux Version [3.3]
Configuration: Default configuration for x86

Function Source:
http://lxr.free-electrons.com/source/net/bluetooth/rfcomm/tty.c?v=3.3#L669

In function (rfcomm_tty_open) in file(linux3.3/net/bluetooth/rfcomm/tty.c):

The mutex object locked by (tty_lock) at line 728 can possibly kept
locked after exiting the function when one of the breaks at lines
(715, 719, or 723) is executed. Causing race conditions if multiple
calls to the same functions occurs with the same errors. Or causing
dangling lock to the mutex object held by (tty_lock).

A possible solution is to call (tty_unlock) upon exiting the function.
Possibly before the break points at lines (715, 719, or 723).



Thanks,
Ahmed
