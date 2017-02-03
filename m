From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next 0/2] net: core: Two Helper function about socket information
Date: Sat, 4 Feb 2017 01:19:28 +0900
Message-ID: <CAKD1Yr3REse_WBB0K3YpGsKKyFYDs6Y6Bpmhv4eE+C4c5d29+A@mail.gmail.com>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com> <20170203001329.GB42563@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:35001 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbdBCQTu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:19:50 -0500
Received: by mail-vk0-f51.google.com with SMTP id x75so16041842vke.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 08:19:49 -0800 (PST)
In-Reply-To: <20170203001329.GB42563@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 9:13 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> I think sk_uid is self explanatory, but cookie is less so.
> Please explain how you plan to use it.

The cookie is the only way to uniquely identify a given socket on the
system (the 5-tuple is not sufficient in the presence of SO_REUSEPORT,
for example). One goal for this infrastructure is to perform
per-socket accounting (ultimately replace the out-of-tree xt_qtaguid
code that is used for per-UID, per-socket-tag accounting on Android).
The socket cookie would be a natural key to use in a BPF map where the
values are socket accounting information.
