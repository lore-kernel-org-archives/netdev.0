From: Tom Gundersen <teg@jklm.no>
Subject: Re: [BUG?] bridge_id not getting set for bridges created with
Date: Mon, 21 Apr 2014 22:56:15 +0200
Message-ID: <CAG-2HqU2f+4i3ttLSeitwr15=cVyin9VT+UrQvKC9pMV04fW7Q@mail.gmail.com>
References: <CAG-2HqVnWXu2dW=Su6DDxDzgg3cLSvTMu5Sf=Eq+YUv4P1d4NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "C. R. Oldham" <cr@saltstack.com>
To: netdev <netdev@vger.kernel.org>,
	bridge <bridge@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:35400 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532AbaDUU4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 16:56:36 -0400
Received: by mail-yh0-f42.google.com with SMTP id v1so2184347yhn.29
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 13:56:36 -0700 (PDT)
In-Reply-To: <CAG-2HqVnWXu2dW=Su6DDxDzgg3cLSvTMu5Sf=Eq+YUv4P1d4NQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 21, 2014 at 9:33 PM, Tom Gundersen <teg@jklm.no> wrote:
> Hi,
>
> If IFLA_ADDRESS is set when creating a bridge over netlink, e.g.
>
> # ip link add test-bridge address b6:83:a2:b3:2f:0e type bride
>
> the bridge id is not set:
>
> # brctl show
> bridge name    bridge id        STP enabled    interfaces
> bridge1        8000.000000000000    no

My example was incomplete. To see the bug one should of course first
add an interface to the bridge:

# brctl addif bridge1 eth0


and observe that the bridge id remains unset:

# brctl show
bridge name    bridge id        STP enabled    interfaces
bridge1        8000.000000000000    no            eth0



If bridge1 had been created without specifying the mac address the
result is as expected:

# brctl show
bridge name    bridge id        STP enabled    interfaces
bridge1        8000.28d244547cdb    no            eth0

Cheers,

Tom
