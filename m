From: Neal Cardwell <ncardwell@google.com>
Subject: Re: A buggy behavior for Linux TCP Reno and HTCP
Date: Fri, 21 Jul 2017 16:49:14 -0400
Message-ID: <CADVnQym8-0-jEaBYpHAodg5ODH6GUCS_tMQbKyWdPKLpxq7ATA@mail.gmail.com>
References: <CANdGJ5Qp1MoGfeSyAnEqYeSeEyoiH8e1j_Ut3F4PnLRBnqNNZg@mail.gmail.com>
 <CAK6E8=eP3jwTD5t7Cj3h_m4JTJ61p=roqsr02WiSHUANse1ynw@mail.gmail.com>
 <CANdGJ5SOUV1OoonC-3i=5MLUWvoHPBZgp19c3mJTTYbNr2yLeQ@mail.gmail.com>
 <CAK6E8=eWYybZZxkjjVXC_K7DfYayEg7gx0bPqKpwi6iuE+bh8Q@mail.gmail.com>
 <dc5db0ec-0746-d42e-5418-f621e1840bc0@unl.edu> <CADVnQynG0MZcuAPpZ+hiK-9Ounx8JKPWxvb1n3t-OyyC7=es_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Yuchung Cheng <ycheng@google.com>, Wei Sun <unlcsewsun@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Lisong Xu <xu@unl.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33987 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdGUUtp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 16:49:45 -0400
Received: by mail-oi0-f46.google.com with SMTP id q4so61301173oif.1
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 13:49:45 -0700 (PDT)
In-Reply-To: <CADVnQynG0MZcuAPpZ+hiK-9Ounx8JKPWxvb1n3t-OyyC7=es_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 21, 2017 at 4:27 PM, Lisong Xu <xu@unl.edu> wrote:
>
> Hi Yuchung,
>
> This test scenario is only one example to trigger this bug. In general, as long as cwnd <4, the undo function has this bug.

Yes, personally I agree that this seems like an issue that is general
enough to be worth fixing. In the sense that, if cwnd <4, then we may
well be very congested. So we don't want to get hit by this bug
wherein an undo of a loss recovery can cause cwnd to suddenly jump
(from 1, 2, or 3) up to 4.

Seems like any of the several CCs that use tcp_reno_undo_cwnd() have this bug.

I guess in my mind the only question is whether we want to add a
tcp_foo_undo_cwnd() and ca->loss_cwnd to every CC module to handle
this issue (i.e. make every CC module handle it the way CUBIC does),
or (my preference) just add a tp->loss_cwnd field so we can use shared
code in tcp_reno_undo_cwnd() to get this right across all CC modules.

neal
