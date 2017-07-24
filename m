From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH V2 net] net: fix tcp reset packet flowlabel for ipv6
Date: Mon, 24 Jul 2017 16:12:53 -0700
Message-ID: <CAM_iQpUGff36UigL39zoh7H=nuzh6EvB6bh4G+jSKsE96uw+aA@mail.gmail.com>
References: <25a0abdf61ab4698773d417af9e49fcd6e6559a4.1500393028.git.shli@fb.com>
 <20170724.133455.562898067272108474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Shaohua Li <shli@kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kernel-team <Kernel-team@fb.com>, Shaohua Li <shli@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>, flo@fourcot.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34828 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753893AbdGXXNO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:13:14 -0400
Received: by mail-wm0-f50.google.com with SMTP id c184so37787124wmd.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 16:13:14 -0700 (PDT)
In-Reply-To: <20170724.133455.562898067272108474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 1:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Shaohua Li <shli@kernel.org>
> Date: Tue, 18 Jul 2017 12:03:37 -0700
>
>> +     /* Since this is being sent on the wire obfuscate hash a bit
>> +      * to minimize possbility that any useful information to an
>> +      * attacker is leaked. Only lower 20 bits are relevant.
>> +      */
>> +     rol32(hash, 16);
>
> This doesn't help anything at all.

I believe the above code is copy-n-pasted from ip6_make_flowlabel()
(with few adjustments). Don't know why we can't refactor that function
for reuse.
