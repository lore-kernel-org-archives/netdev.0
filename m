From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH resend net-next 0/3] myri10ge: LRO to GRO conversion
Date: Wed, 28 Nov 2012 16:20:35 -0500
Message-ID: <50B68023.4030208@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:64750 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543Ab2K1VUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 16:20:39 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so2171813ghb.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 13:20:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following patchset is a re-send of one I sent a few weeks
back, and converts myri10ge from using the old inet_lro
interface to GRO.

Note that a naive LRO->GRO conversion of myri10ge will result in a
performance regression for vlan tagged frames.  This is because
myri10ge does not offer hardware vlan tag offload, and because GRO
requires hardware vlan tag offload to aggregate vlan tagged frames.

To address this performance regression, I have implemented vlan tag
popping in the myri10ge driver, as it seems to be the lesser of two
evils.  As eric.dumazet@gmail.com commented when I asked about this on
netdev: "Given GRO assumes NIC does hardware vlan
offloading, I guess I would chose to do that.  It seems unfortunate to
add vlan decap in GRO path, already very complex."


Andrew Gallatin (3):
myri10ge: Convert from LRO to GRO
myri10ge: Add vlan rx for better GRO perf.
myri10ge: Use skb_fill_page_desc().

  drivers/net/ethernet/myricom/Kconfig             |    1 -
  drivers/net/ethernet/myricom/myri10ge/myri10ge.c |  274 
++++++----------------
  2 files changed, 73 insertions(+), 202 deletions(-)
