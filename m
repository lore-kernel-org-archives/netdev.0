From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Question] What's the noop_qdisc introduced for in the kernel?
Date: Tue, 30 Dec 2014 12:15:01 -0800
Message-ID: <CAHA+R7O_ypxh4DjQ1eeKZyGFpYbKQAgKkEjrmk400Ud+zLeEow@mail.gmail.com>
References: <CA+U0gVi=DTpz-Givbrs771+KYz8EE1ABdy2oO38q4LR9fG37YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Dennis Chen <kernel.org.gnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:43336 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbaL3UPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 15:15:03 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so10831480qcz.19
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 12:15:02 -0800 (PST)
In-Reply-To: <CA+U0gVi=DTpz-Givbrs771+KYz8EE1ABdy2oO38q4LR9fG37YQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2014 at 1:23 AM, Dennis Chen <kernel.org.gnu@gmail.com> wrote:
> After google and the code reading, seems this Qdisc instance is only
> used for the initialization purpose, I can't find the reason that this
> object introduced in the kernel. Does anybody know what the historical
> reason is for this invention? the purpose or the benefit for this
> Qdisc object?
>

Not just for initialization, it is kinda a null qdisc when
the previous qdisc gets removed:

        /* ... and graft new one */
        if (qdisc == NULL)
                qdisc = &noop_qdisc;

or the entire device is not activated yet. It guarantees no
packets can be sent out via this qdisc.
