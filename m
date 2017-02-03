From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Understanding mutual exclusion between rtnl_lock and rcu_read_lock
Date: Fri, 3 Feb 2017 13:40:23 -0800
Message-ID: <CAM_iQpU+5JP+tBcDuBnLd_WnY1DuymJ6ukxcJJSq4E3p9Pah=A@mail.gmail.com>
References: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com> <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
 <096DC091-F762-4401-9AE1-22AF6899BACB@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joel Cunningham <joel.cunningham@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33431 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752696AbdBCVkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:40:45 -0500
Received: by mail-wm0-f66.google.com with SMTP id v77so7188816wmv.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:40:44 -0800 (PST)
In-Reply-To: <096DC091-F762-4401-9AE1-22AF6899BACB@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 6:05 PM, Joel Cunningham <joel.cunningham@me.com> wr=
ote:
>
> In the case of SIOCSIFHWADDR, we get a pointer to the net_device through =
__dev_get_by_name() and then pass it to dev_set_mac_address() to modify thr=
ough ndo_set_mac_address().  I didn=E2=80=99t see any uses of RCU APIs on t=
he writer side and that=E2=80=99s why I figured there was something going o=
n with rtnl_lock() that I didn=E2=80=99t understand or that the dev_ioctl f=
unction wasn=E2=80=99t re-entrant from another CPU
>

You are right, that RCU read lock could merely protect the netdevice from
being unregistered concurrently, can't prevent a concurrent dev_ifsioc().

I don't know why Eric changed it to RCU read lock, it is not a hot path, us=
ing
rtnl lock is fine and can guarantee a atomic read.
