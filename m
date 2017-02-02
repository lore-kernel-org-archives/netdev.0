From: Joel Cunningham <joel.cunningham@me.com>
Subject: Understanding mutual exclusion between rtnl_lock and rcu_read_lock
Date: Thu, 02 Feb 2017 17:47:23 -0600
Message-ID: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pv38p43im-ztdg05071201.me.com ([17.133.183.8]:43917 "EHLO
        pv38p43im-ztdg05071201.me.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751595AbdBBXr0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 18:47:26 -0500
Received: from process-dkim-sign-daemon.pv38p43im-ztdg05071201.me.com by
 pv38p43im-ztdg05071201.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OKR00N00U03H900@pv38p43im-ztdg05071201.me.com> for
 netdev@vger.kernel.org; Thu, 02 Feb 2017 23:47:25 +0000 (GMT)
Received: from icloud.com ([127.0.0.1]) by pv38p43im-ztdg05071201.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 with ESMTPSA id <0OKR003AIU2ZE840@pv38p43im-ztdg05071201.me.com> for
 netdev@vger.kernel.org; Thu, 02 Feb 2017 23:47:25 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I=E2=80=99m studying the synchronization used on different parts of =
struct net_device and I=E2=80=99m struggling to understand how structure =
member modifications in dev_ioctl are synchronized.  Getters in =
dev_ifsioc_locked() are only holding rcu_read_lock() while setters in =
dev_ifsioc() are holding rtnl_lock, but not using RCU APIs.  I was =
specifically looking at SIOCGIFHWADDR/SIOCSIFHWADDR.  What=E2=80=99s to =
prevent one CPU from executing a getter and another CPU from executing a =
setter resulting in possibly a torn read/write?  I didn=E2=80=99t see =
anything in rtnl_lock() that would wait for any rcu_reader_lock() =
critical sections (on other CPUs) to finish before acquiring the mutex.

Is there something about dev_ioctl that prevents parallel execution? or =
maybe something I still don=E2=80=99t understand about the RCU =
implementation?

Thanks,

Joel=
