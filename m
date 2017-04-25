From: Tom Herbert <tom@herbertland.com>
Subject: TCP fast open using experimental TCP option?
Date: Tue, 25 Apr 2017 12:08:47 -0700
Message-ID: <CALx6S36L4BbdcASbGNvn6mRMJDhJJ6n8y-uRTgVqteM=f6On6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:34938 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1953725AbdDYTIt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 15:08:49 -0400
Received: by mail-qt0-f178.google.com with SMTP id y33so148445810qta.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 12:08:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like TCP fast open was using experimental TCP option at some. Is
this still needed? Technically this violates usage requirements of
experimental options. Can this be removed now since there is now an
assigned option number for TFO?

                             case TCPOPT_EXP:
                                /* Fast Open option shares code 254 using a
                                 * 16 bits magic number.
                                 */
                                if (opsize >= TCPOLEN_EXP_FASTOPEN_BASE &&
                                    get_unaligned_be16(ptr) ==
                                    TCPOPT_FASTOPEN_MAGIC)
                                        tcp_parse_fastopen_option(opsize -
                                                TCPOLEN_EXP_FASTOPEN_BASE,
                                                ptr + 2, th->syn, foc, true);
                                break;
