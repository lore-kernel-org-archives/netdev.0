From: Jiri Slaby <jirislaby@gmail.com>
Subject: sch_atm: null dereference
Date: Sat, 04 Sep 2010 14:37:52 +0200
Message-ID: <4C823DA0.3050203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34350 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab0IDMh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 08:37:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

stanse found a potential null dereference:
atm_tc_change
  -> if (flow)
    -> return -EBUSY;
  -> flow is NULL now
  -> if (classid)
    -> if (!list_empty(&flow->list))

Introduced probably in
    sch_atm: Convert to use standard list_head facilities.

Could you fix that?

regards,
-- 
js
