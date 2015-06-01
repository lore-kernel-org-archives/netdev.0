From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] vlan: Add GRO support for non hardware
 accelerated vlan
Date: Mon, 01 Jun 2015 09:28:41 -0700
Message-ID: <1433176121.1895.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1433167957.1895.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <556C8244.1090400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33170 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbbFAQ2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 12:28:44 -0400
Received: by iebgx4 with SMTP id gx4so112939150ieb.0
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 09:28:43 -0700 (PDT)
In-Reply-To: <556C8244.1090400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-02 at 01:03 +0900, Toshiaki Makita wrote:

> I didn't have that concern because there are already other similar 
> offloads (eth, mpls_uc, mpls_mc). But indeed, they and this could slow 
> down GRO stack.

Right, but these mpls offloads are not installed on my kernels ;)

And I already checked that eth was installed before IPv4/IPv6,
although it might be pure luck.



> Add priority to packet_offload like nf_hook_ops?
> Or have dev_add_offload() prioritize IP > IPV6 > others?


You also could use a CONFIG_NET_VLAN_GRO module, so that only
users stuck with non accelerated vlan can load.

But yes, we might take care of this problem at some point.
