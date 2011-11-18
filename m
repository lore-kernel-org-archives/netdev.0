From: Madhvapathi Sriram <sriram.madhvapathi@gmail.com>
Subject: query : unregister/register netdev
Date: Fri, 18 Nov 2011 17:53:37 +0530
Message-ID: <CAAvRe=jhfXEnLFkwbPmWEroDE-qHUpZ54TSSdw=WpmfPGZpsPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:59896 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab1KRMXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 07:23:37 -0500
Received: by ywt32 with SMTP id 32so2367939ywt.19
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2011 04:23:37 -0800 (PST)
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
