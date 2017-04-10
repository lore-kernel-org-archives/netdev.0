From: Tom Herbert <tom@herbertland.com>
Subject: RFC: Checksum offload and XDP
Date: Mon, 10 Apr 2017 11:26:36 -0700
Message-ID: <CALx6S357=e3414sPBnW3ajzXfkvVBiGMChx+vgbf9snpe95-aQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:34577 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751780AbdDJS0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 14:26:38 -0400
Received: by mail-qt0-f182.google.com with SMTP id c45so71115980qtb.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 11:26:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not having checksum offload in XDP is going to get more painful once
we start seeing a lot programs doing packet modifications. One nice
thing we do for ILA router is pre-compute the checksum delta necessary
to maintain checksum neutral property in the packet. So that after
doing ILA routing in XDP the checksum complete value is still valid as
is the transport layer checksum.

It's conceivable we could generalize this by having a u16 checksum
delta returned from XDP program. If the checksum diff can be
pre-computed in a structure for doing the translation, then there
should be little cost other than making API a little more complex. On
return the checksum_complete value is updated jusy by adding in the
diff value.

Tom
