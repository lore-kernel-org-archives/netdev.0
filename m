From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v2] net: heap overflow in __audit_sockaddr()
Date: Wed, 27 Nov 2013 12:24:41 -0800
Message-ID: <CA+55aFwP5NWG9doOqZRy7fBdUpwW-bDwEJxjMV0Yr3q3Y=30Fg@mail.gmail.com>
References: <1380748306.1795.67.camel@bwh-desktop.uk.level5networks.com>
	<20131002212720.GA30492@elgon.mountain>
	<20131127113218.GB1612@dcvr.yhbt.net>
	<20131127115120.GC20630@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Eric Wong <normalperson@yhbt.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>,
	=?UTF-8?Q?J=C3=BCri_Aedla?= <juri.aedla@gmail.com>,
	"# .39.x" <stable@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f169.google.com ([209.85.128.169]:56139 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758374Ab3K0UYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 15:24:42 -0500
Received: by mail-ve0-f169.google.com with SMTP id c14so5715492vea.28
        for <netdev@vger.kernel.org>; Wed, 27 Nov 2013 12:24:41 -0800 (PST)
In-Reply-To: <20131127115120.GC20630@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 27, 2013 at 3:51 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> We have to clamp msg_namelen to max sizeof(struct sockaddr_storage).
> The sendmsg handler will check msg_namelen again and error out correctly if
> the size of msg_name is too short.

Yeah, clamping sounds like the right thing to do at least for
receiving. For sending, you should say "we can't send packets that big
due to memory constraints" (of, for the case of a sockaddr, "to an
address this big"), but for receiving the size of the user space
buffer is kind of irrelevant - if the user gives a bigger buffer than
necessary, who cares? We just need to make sure that the kernel
doesn't then allocate silly-big temporary buffers internally.

There seems to be a patch floating around to clamp things already.

                Linus
