From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 1/8] net: local checksum offload for encapsulation
Date: Thu, 28 Jan 2016 01:00:43 -0800
Message-ID: <CAKgT0UcA5kAg64QPL=L=SYw3O=f+KDwcqgMEziCs=AYL439FYA@mail.gmail.com>
References: <56901197.8040808@solarflare.com>
	<569011D4.60002@solarflare.com>
	<56A9BD8E.4030209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com, Tom Herbert <tom@herbertland.com>
To: Zang MingJie <zealot0630@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35263 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755205AbcA1JAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 04:00:43 -0500
Received: by mail-io0-f169.google.com with SMTP id d63so30810077ioj.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 01:00:43 -0800 (PST)
In-Reply-To: <56A9BD8E.4030209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2016 at 11:04 PM, Zang MingJie <zealot0630@gmail.com> wrote:
> I have also noticed that for gso, all gso segs will have exactly same outer
> udp checksum, this is also because inner checksum cancellation.
>
> Can we also optimize that outer udp checksum should be only calculated once
> for all gso segs ?

Actually that is a good point.  It isn't as if anything really changes
in the tunnel headers between frames so we probably can just compute
the outer once and then adjust it on the last frame to account for the
fact that the length will be different.  I'll see if we can do that in
the GSO patches I have been working on.

- Alex
