From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: iproute2: iplink_ stuff cleanup
Date: Thu, 15 Mar 2012 14:53:51 +0100
Message-ID: <CAGm1_kuHYCRuoUEfBeV6GbjypUJgr1_058f-e4AhojHP1fTJWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:45947 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab2CONyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 09:54:14 -0400
Received: by gghe5 with SMTP id e5so3057046ggh.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 06:54:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

I'm still struggling to get ip/iplink_* routines to show up in
Android's ip binary
(https://groups.google.com/d/topic/android-building/yjV4iYnT1Zc/discussion).
I've looked at the algorithm that is used to access those functions
(like can_parse_opt, vlan_parse_opt etc.)

 snprintf(buf, sizeof(buf), LIBDIR "/ip/link_%s.so", id);
        dlh = dlopen(buf, RTLD_LAZY);
        if (dlh == NULL) {
                /* look in current binary, only open once */
                dlh = BODY;
                if (dlh == NULL) {
                        dlh = BODY = dlopen(NULL, RTLD_LAZY);
                        if (dlh == NULL)
                                return NULL;
                }
        }

        snprintf(buf, sizeof(buf), "%s_link_util", id);
        l = dlsym(dlh, buf);
        if (l == NULL)
                return NULL;

as far as I can see from the ip/Makefile there are no dynamic libs
like /ip/link_%s.so. Wouldn't it be simpler to let all iplink_*
objects to export their interfaces via header files and just make a
table in ip/iplink.c to hold protocol ID and pointer at link_utils
struct.

struct link_util can_link_util = {
        .id             = "can",
        .maxattr        = IFLA_CAN_MAX,
        .parse_opt      = can_parse_opt,
        .print_opt      = can_print_opt,
        .print_xstats   = can_print_xstats,
};

Am I missing something?

Regards,
Yegor
