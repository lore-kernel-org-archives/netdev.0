From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH,net-next,0/2] Improve code coverage of syzkaller
Date: Wed, 20 Sep 2017 11:38:45 -0400
Message-ID: <CAF=yD-J_qL=hkgnbgPmHW3o_iC6WKmqFUZmmzQKs-+AUhEWY-Q@mail.gmail.com>
References: <20170919073402.2292-1-peterpenkov96@gmail.com>
 <20170919.160134.534837308168786965.davem@davemloft.net> <CA+DcSEjDe=h5Kk2Bg0vCOatQj2Zs8wTAyVH+z5curg4O4c3=Hw@mail.gmail.com>
 <20170919.230853.540610280718334640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: peterpenkov96@gmail.com,
        Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36341 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdITPj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 11:39:26 -0400
Received: by mail-oi0-f66.google.com with SMTP id a74so1544436oib.3
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 08:39:26 -0700 (PDT)
In-Reply-To: <20170919.230853.540610280718334640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 2:08 AM, David Miller <davem@davemloft.net> wrote:
> From: Petar Penkov <peterpenkov96@gmail.com>
> Date: Tue, 19 Sep 2017 21:26:14 -0700
>
>> Furthermore, in a way testing already requires specific kernel
>> configuration.  In this particular example, syzkaller prefers
>> synchronous operation and therefore needs 4KSTACKS disabled. Other
>> features that require rebuilding are KASAN and dbx. From this point
>> of view, I still think that having the TUN_NAPI flag has value.
>
> Then I think this path could be enabled/disabled with a runtime flag
> just as easily, no?

I think that the compile time option was chosen because of the ns_capable
check, so that with user namespaces unprivileged processes can control this
path. Perhaps we can require capable() only to set IFF_NAPI_FRAGS.

Then we can convert the napi_gro_receive path to be conditional on a new
IFF_NAPI flag instead of this compile time option.
