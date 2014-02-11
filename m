From: Cong Wang <cwang@twopensource.com>
Subject: Q: why calling kobject_put() twice?
Date: Tue, 11 Feb 2014 14:24:06 -0800
Message-ID: <CAHA+R7NMp_cvVCVhaYk--Yh=0KrEE-TKZXfk1MFGjWymC8dzLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:59753 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbaBKWYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 17:24:08 -0500
Received: by mail-la0-f42.google.com with SMTP id hr13so6529101lab.1
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 14:24:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


There are many drivers either using free_netdev() as ->destructor() or
calling it in their own destructor(), and in free_netdev() we call
put_device(&dev->dev) at last. But in netdev_run_todo(), we call
kobject_put(&dev->dev.kobj) again after calling ->destructor(). So,
what's the point of doing this?

Also, if free_netdev() is supposed to free the netdev as its name
tells, then why it's still safe to read some field of it after that?

I must miss something here.

Thanks.
