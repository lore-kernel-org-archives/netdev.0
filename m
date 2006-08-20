From: Denis Vlasenko <vda.linux@googlemail.com>
Subject: 800+ byte inlines in include/net/pkt_act.h
Date: Sun, 20 Aug 2006 19:33:10 +0200
Message-ID: <200608201933.10293.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:51844 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751008AbWHTRdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 13:33:45 -0400
Received: by py-out-1112.google.com with SMTP id n25so2078208pyg
        for <netdev@vger.kernel.org>; Sun, 20 Aug 2006 10:33:45 -0700 (PDT)
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

include/net/pkt_act.h plays a game of inlines
which are kind of "templatized", like this:

act_ipt.c:

/* ovewrride the defaults */
#define tcf_st          tcf_ipt
#define tcf_t_lock      ipt_lock
#define tcf_ht          tcf_ipt_ht
#define CONFIG_NET_ACT_INIT
#include <net/pkt_act.h>

This results in code duplication. For example,
tcf_generic_walker() is duplicated four times.
On i386 it is about 4*800 bytes in text section.
Other inlines are a bit smaller but still are substantial.
--
vda
