From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Fri, 8 Jan 2016 14:07:09 -0800
Message-ID: <CALx6S35dtd8Pg4zvhZk2v5pNr_RqYG1Nk6zSyxFq6+8OChDpNA@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com>
	<568E9C9B.3090408@solarflare.com>
	<CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
	<568FD844.3020101@solarflare.com>
	<CAKgT0Uc7K1tmwSmdi2uftJSHr4E5DKKYHxO1Gn50eCCWPaTurw@mail.gmail.com>
	<CAEh+42iX4AxEektcKSSeJ+OKX5Paa+ZY5T9vXC5KYtiLvjqixg@mail.gmail.com>
	<CAKgT0UcbH-BVbGxOuKx2EeX_Z5SgV8fdhDRjgoSC2eQTDjxNmQ@mail.gmail.com>
	<56902BF8.6080004@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Jesse Gross <jesse@kernel.org>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34168 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbcAHWHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 17:07:10 -0500
Received: by mail-io0-f194.google.com with SMTP id k127so38635435iok.1
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 14:07:10 -0800 (PST)
In-Reply-To: <56902BF8.6080004@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 1:36 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 01/08/2016 01:22 PM, Alexander Duyck wrote:
>>
>>  and we don't require the remote end to validate the outer checksum.
>
>
> Doesn't the UDP specification require validating a non-zero checksum on
> receipt?
>
Yes, VXLAN RFC is broken in this regard since it allows a receiver to
ignore a non-zero checksums. In Linux we always validate non-zero
checksums.

For VXLAN, UDP checksums are not enabled for IPv4 by default, but are
enabled by default for IPv6. Checksums are required for UDP/IPv6,
however RFC6935 and RFC6936 relax this requirement a bit for tunnels,
although IMO not enough to make disabling UDP checksums for VXLAN/IPv6
the default.

Tom

> rick jones
>
