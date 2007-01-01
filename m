From: "=?ISO-8859-1?Q?Daniel_Marjam=E4ki?=" <daniel.marjamaki@gmail.com>
Subject: Re: [PATCH] net/core/flow.c: compare data with memcmp
Date: Mon, 1 Jan 2007 08:47:48 +0100
Message-ID: <80ec54e90612312347w2b906e5eg725a7761110c6897@mail.gmail.com>
References: <80ec54e90612310837y786fd764oc18bf37c8f0b2b8c@mail.gmail.com>
	 <20061231.123715.115911390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:23841 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932943AbXAAHrt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jan 2007 02:47:49 -0500
Received: by nf-out-0910.google.com with SMTP id o25so6873163nfa
        for <netdev@vger.kernel.org>; Sun, 31 Dec 2006 23:47:48 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061231.123715.115911390.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

So you mean that in this particular case it's faster with a handcoded
comparison than memcmp? Because both key1 and key2 are located at
word-aligned addresses?
That's fascinating.

Best regards,
Daniel

2006/12/31, David Miller <davem@davemloft.net>:
> From: "Daniel_Marjam=E4ki" <daniel.marjamaki@gmail.com>
> Date: Sun, 31 Dec 2006 17:37:05 +0100
>
> > From: Daniel Marjam=E4ki
> > This has been tested by me.
> > Signed-off-by: Daniel Marjam=E4ki <daniel.marjamaki@gmail.com>
>
> Please do not do this.
>
> memcmp() cannot assume the alignment of the source and
> destination buffers and thus will run more slowly than
> that open-coded comparison.
>
> That code was done like that on purpose because it is
> one of the most critical paths in the networking flow
> cache lookup which runs for every IPSEC packet going
> throught the system.
>
