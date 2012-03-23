From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] skb truesize last offenders
Date: Fri, 23 Mar 2012 05:51:52 -0700
Message-ID: <1332507112.4858.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:60419 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755201Ab2CWMv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 08:51:56 -0400
Received: by yenl12 with SMTP id l12so2669779yen.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 05:51:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iwlwifi and some other users of skb_add_rx_frag() lie about skb
truesize, because of API being lazy.

iwlwifi can use order-0 or order-1 pages and skb truesize is wrong.
network sbs can use uncharged kernel memory and eventually crash machine
in OOM.

I plan : 

1) adding a @truesize parameter to skb_add_rx_frag() in a neutral patch

2) fix drivers that dont charge the real size of fragment

3) niu could then use skb_add_rx_frag() instead of custom code.
