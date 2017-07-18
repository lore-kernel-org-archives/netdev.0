From: Dmitry <d.andreev@uni-eng.ru>
Subject: [BUG] /net/hsr: prune_timer
Date: Tue, 18 Jul 2017 11:07:39 +0300
Message-ID: <op.y3kbi1pqlevu92@dandreev01.uni-eng.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback15.m.smailru.net ([94.100.179.50]:44780 "EHLO
        fallback.mail.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751380AbdGRIHq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:07:46 -0400
Received: from [10.161.64.61] (port=53056 helo=smtp53.i.mail.ru)
        by fallback15.m.smailru.net with esmtp (envelope-from <d.andreev@uni-eng.ru>)
        id 1dXNXh-0007ZK-UC
        for netdev@vger.kernel.org; Tue, 18 Jul 2017 11:07:43 +0300
Received: by smtp53.i.mail.ru with esmtpa (envelope-from <d.andreev@uni-eng.ru>)
        id 1dXNXf-0003B6-Jk
        for netdev@vger.kernel.org; Tue, 18 Jul 2017 11:07:39 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!


void hsr_prune_nodes(unsigned long data) called once by timer.

hsr_prune_nodes must be called periodically every PRUNE_PERIOD (60s).




This code want be added to tail of hsr_prune_nodes function

hsr->prune_timer.expires = jiffies + msecs_to_jiffies(PRUNE_PERIOD);
add_timer(&hsr->prune_timer);

or

mod_timer(&hsr->prune_timer, jiffies + msecs_to_jiffies(PRUNE_PERIOD));
