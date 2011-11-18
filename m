From: Madhvapathi Sriram <sriram.madhvapathi@gmail.com>
Subject: (unknown)
Date: Fri, 18 Nov 2011 17:48:49 +0530
Message-ID: <CAAvRe=hu22AzJteJewj1TpdTVNa9xz5znctQM+YJuX9WxhBr8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34167 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755695Ab1KRMSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 07:18:51 -0500
Received: by ghbz2 with SMTP id z2so465434ghb.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 04:18:50 -0800 (PST)
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In register_netdevice(), BUG_ON(dev->reg_state != NETREG_UNINITIALIZED) is
used to check if the device that is being registered is indeed a new one.

However, I see that this state is never moved to. It only happens when a
netdevice is allocated (by default to 0 using kzalloc).

So, the cycle register-->unregister-->register would fail since in the
unregister_netdevice the state is only moved to NETREG_UNREGISTERED (at max
to NETREG_RELEASED using free_netdev)

So, I presume that to reinitialize a netdevice one has to free the
netdevice, re allocate netdevice and only then re register.

Wondering why unregister and reregister is not allowed, rather than having
go through the free/alloc cycle - I am not an expert though.

Thanks
-Sriram
