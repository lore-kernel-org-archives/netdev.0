From: Tom Herbert <therbert@google.com>
Subject: Question about locks in qdisc_restart
Date: Mon, 27 Apr 2009 12:48:57 -0700
Message-ID: <65634d660904271248p133717aam55751fc435f9fd3e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:6343 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbZD0TtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 15:49:01 -0400
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n3RJmxkS003290
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 20:49:00 +0100
Received: from qyk8 (qyk8.prod.google.com [10.241.83.136])
	by wpaz21.hot.corp.google.com with ESMTP id n3RJmarR026431
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 12:48:58 -0700
Received: by qyk8 with SMTP id 8so252235qyk.19
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 12:48:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In qdisc_restart the qdisc lock is released before taking the
netif_tx_lock, and only acquired again after unlocking the
netif_tx_lock.  There's a comment with the function that
"qdisc_lock(q) and netif_tx_lock are mutually exclusive, if one is
grabbed, another must be free."  Can anyone tell me the motivation for
this restriction?  We are seeing some performance improvements by
holding the lock through qdisc_restart, and I'm not sure why this
would be bad to do.

Thanks,
Tom
