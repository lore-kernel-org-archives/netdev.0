From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Understanding mutual exclusion between rtnl_lock and rcu_read_lock
Date: Thu, 2 Feb 2017 15:52:06 -0800
Message-ID: <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
References: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joel Cunningham <joel.cunningham@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:36424 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdBBXwH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 18:52:07 -0500
Received: by mail-it0-f44.google.com with SMTP id c7so1164036itd.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 15:52:07 -0800 (PST)
In-Reply-To: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 3:47 PM, Joel Cunningham <joel.cunningham@me.com> wr=
ote:
> Hi,
>
> I=E2=80=99m studying the synchronization used on different parts of struc=
t net_device and I=E2=80=99m struggling to understand how structure member =
modifications in dev_ioctl are synchronized.  Getters in dev_ifsioc_locked(=
) are only holding rcu_read_lock() while setters in dev_ifsioc() are holdin=
g rtnl_lock, but not using RCU APIs.  I was specifically looking at SIOCGIF=
HWADDR/SIOCSIFHWADDR.  What=E2=80=99s to prevent one CPU from executing a g=
etter and another CPU from executing a setter resulting in possibly a torn =
read/write?  I didn=E2=80=99t see anything in rtnl_lock() that would wait f=
or any rcu_reader_lock() critical sections (on other CPUs) to finish before=
 acquiring the mutex.
>
> Is there something about dev_ioctl that prevents parallel execution? or m=
aybe something I still don=E2=80=99t understand about the RCU implementatio=
n?
>
> Thanks,
>
> Joel

My advice would be to spend more time familiarizing yourself with RCU.
The advantage of RCU is that it allows for updates while other threads
are accessing the data.  The rtnl_lock is just meant to prevent
multiple writers from updating the data simultaneously.  So between
writers the rtnl_lock is used to keep things synchronized, but between
writers and readers the mechanism that is meant to protect the data
and keep it sane is RCU.

- Alex
