From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Re: [PATCH net] ppp: Fix a scheduling-while-atomic bug in del_chan
Date: Mon, 7 Aug 2017 10:34:34 -0700
Message-ID: <CAM_iQpUv9_1Y6hHd-R8KqzSP4G4+96FrrCQm7WeQACv+uHCW_Q@mail.gmail.com>
References: <1501495658-119725-1-git-send-email-gfree.wind@vip.163.com>
 <CAM_iQpVEsTpg17RZ1Y1jN2e0wb_X6gtxx05rmUSGa=A=XSj=Eg@mail.gmail.com>
 <CAM_iQpVta2EFVjutndCmoLBPWko7dgzP=Q1i2krPqyYuNBV4RA@mail.gmail.com>
 <31c9755c.ff6.15dba5238fc.Coremail.gfree.wind@vip.163.com> <CAM_iQpWmJmk=_yoV8=krOWonE_0orTC5Z4GaCnPg8Jv3GX6dmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: xeb@mail.ru, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34876 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdHGRez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:34:55 -0400
Received: by mail-vk0-f65.google.com with SMTP id j189so524629vka.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 10:34:55 -0700 (PDT)
In-Reply-To: <CAM_iQpWmJmk=_yoV8=krOWonE_0orTC5Z4GaCnPg8Jv3GX6dmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 7, 2017 at 10:17 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Unless I miss any other code path, pptp_exit_module() is
> problematic too, I don't think it can just vfree() the whole thing.
>

This path should be fine, because:

1. sock holds a refcnt to module via proto->owner
2. gre_del_protocol() already waits for readers
