From: =?UTF-8?B?7ZmN7IugIHNoaW4gaG9uZw==?= <hongshin@gmail.com>
Subject: BUG? racy code at net/atm/br2684.c
Date: Thu, 17 Feb 2011 13:49:46 +0900
Message-ID: <AANLkTi=f_UUoLSdv6zf3-kghu-jyPTGo9Vg1i3_F-5J+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:33169 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051Ab1BQEtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 23:49:47 -0500
Received: by qyj19 with SMTP id 19so4542065qyj.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 20:49:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi. I am reporting a suspected race bug at br2684_push()
in /net/atm/br2684.c.

Please examine the report and let me know your opinion.
I reported the same issue several month ago and got feedback
however, I found that the code is still not changed.

In br2684_push() accesses &brdev->brvcss without devs_lock holding at line 334.
But it seems that all accesses to &brdev->brvcss are synchronized by devs_lock.

So that br2684_push() may result race condition in concurrent execution
with other functions that manipulate &brdev->brvcss.

It seems that it is better to guard list_empty(&brdev->brvccs) by devs_lock.
Or check list_empty(&brdev->brvccs) once again after devs_lock holding.



Thank you.

Sincerely
Shin Hong
