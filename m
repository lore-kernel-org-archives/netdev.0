From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] packet: clean up error variable
 assignments
Date: Tue, 23 Oct 2012 19:05:52 +0200
Message-ID: <1351011952.8609.2334.camel@edumazet-glaptop>
References: <20121023115629.GA8664@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dxchgb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56131 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932821Ab2JWRF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:05:57 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1701076bkc.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:05:56 -0700 (PDT)
In-Reply-To: <20121023115629.GA8664@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-23 at 13:56 +0200, Daniel Borkmann wrote:
> This patch performs clean-ups of packet's err variables where appropriate.
> In particular, errnos are *only* assigned in error cases, which saves
> useless instructions in non-error cases and makes the code more readable
> in terms of which error type belongs to which evaluated error condition.
> Also, in some cases an errno was set, but not used until the next assignment.

I see no value in this patch.

Setting err before a test is a common way to handle error cases and
generates smaller code in linux kernel.

Better live with it than trying to change it ?

err = -ENOMEM;
match = kzalloc(xxxx);
if (!match)
	goto error;


is smaller (source code & generated code) than :

match = kzalloc(xxxx);
if (!match) {
	err = -ENOMEM;
	goto error;
}

An immediate load is basically free, but code size matters.
