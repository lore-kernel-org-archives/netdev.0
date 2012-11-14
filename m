From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net-next 0/3] myri10ge: LRO to GRO conversion
Date: Wed, 14 Nov 2012 08:06:15 -0500
Message-ID: <50A39747.3030207@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:47427 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422804Ab2KNNGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 08:06:18 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so46690yhm.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 05:06:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following patchset converts myri10ge from using the old inet_lro
interface to GRO.

Note that a naive LRO->GRO conversion of myri10ge will result in a
performance regression for vlan tagged frames.  This is because
myri10ge does not offer hardware vlan tag offload, and because GRO
requires hardware vlan tag offload to aggregate vlan tagged frames.

To address this performance regression, I have implemented vlan tag
popping in the myri10ge driver, as it seems to be the lesser of two
evils.  As eric.dumazet@gmail.com commented when I asked about this on
netdev last week: "Given GRO assumes NIC does hardware vlan
offloading, I guess I would chose to do that.  It seems unfortunate to
add vlan decap in GRO path, already very complex."


Andrew Gallatin (3):
myri10ge: Convert from LRO to GRO
myri10ge: Add vlan rx for better GRO perf.
myri10ge: Use skb_fill_page_desc().


  drivers/net/ethernet/myricom/Kconfig             |    1 -
  drivers/net/ethernet/myricom/myri10ge/myri10ge.c |  281 
++++++----------------
  2 files changed, 80 insertions(+), 202 deletions(-)
