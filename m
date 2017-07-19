From: Yuchung Cheng <ycheng@google.com>
Subject: Re: A buggy behavior for Linux TCP Reno and HTCP
Date: Wed, 19 Jul 2017 12:31:57 -0700
Message-ID: <CAK6E8=eP3jwTD5t7Cj3h_m4JTJ61p=roqsr02WiSHUANse1ynw@mail.gmail.com>
References: <CANdGJ5Qp1MoGfeSyAnEqYeSeEyoiH8e1j_Ut3F4PnLRBnqNNZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>
To: Wei Sun <unlcsewsun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37196 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753057AbdGSTcj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 15:32:39 -0400
Received: by mail-wm0-f50.google.com with SMTP id g127so8101953wmd.0
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 12:32:39 -0700 (PDT)
In-Reply-To: <CANdGJ5Qp1MoGfeSyAnEqYeSeEyoiH8e1j_Ut3F4PnLRBnqNNZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 2:36 PM, Wei Sun <unlcsewsun@gmail.com> wrote:
> Hi there,
>
> We find a buggy behavior when using Linux TCP Reno and HTCP in low
> bandwidth or highly congested network environments.
>
> In a simple word, their undo functions may mistakenly double the cwnd,
> leading to a more aggressive behavior in a highly congested scenario.
>
>
> The detailed reason:
>
> The current reno undo function assumes cwnd halving (and thus doubles
> the cwnd), but it doesn't consider a corner case condition that
> ssthresh is at least 2.
>
> e.g.,
>                          cwnd              ssth
> An initial state:     2                    5
> A spurious loss:   1                    2
> Undo:                   4                    5
>
> Here the cwnd after undo is two times as that before undo. Attached is
> a simple script to reproduce it.
the packetdrill script is a bit confusing: it disables SACK but then
the client returns ACK w/ SACKs, also 3 dupacks happen after RTO so
the sender isn't technically going through a fast recovery...

could you provide a better test?

>
> A similar reason for HTCP, so we recommend to store the cwnd on loss
> in .ssthresh implementation and restore it again in .undo_cwnd for TCP
> Reno and HTCP implementations.
>
> Thanks
