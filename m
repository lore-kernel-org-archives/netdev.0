From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: ip rule and/or route problem in 2.6.37-rc5+
Date: Thu, 23 Dec 2010 10:22:23 +0100
Message-ID: <AANLkTin0mNkfaDvs3ZrEhxY27kdmZLh8ikKNpc-MXC44@mail.gmail.com>
References: <4D017D0D.50907@candelatech.com>
	<4D01C65A.6090200@candelatech.com>
	<4D07E18F.30703@candelatech.com>
	<20101219.214230.39170893.davem@davemloft.net>
	<AANLkTikNk8Ltei+jxpJuVqNxbhc-hhMpjc89YDvbirQK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, greearb@candelatech.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50344 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab0LWJWY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 04:22:24 -0500
Received: by wyb28 with SMTP id 28so5867217wyb.19
        for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 01:22:23 -0800 (PST)
In-Reply-To: <AANLkTikNk8Ltei+jxpJuVqNxbhc-hhMpjc89YDvbirQK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 18:22, Tom Herbert <therbert@google.com> wrote:
>> Tom, please acknowledge this regression you've added to the tree.
>
> Acknowledged. =C2=A0Looking at it.
>
> Tom

This is definitely a regression, and the fault is definitely with this =
code.

Indeed, the code is fundamentally flawed.  I've been trying to come up
with a fix, but I'm beginning to think we're barking up the wrong tree
here.
Currently my preference is leaning towards using setsockopt(SOL_IP,
IP_TRANSPARENT) [possibly with some sk->transparent tcp inheritence
fixes] instead.
I definitely want this functionality though, since it's wonderfully
useful for testing (and for serving as well).

Could we please revert this ( 4465b469008bc03b98a1b8df4e9ae501b6c69d4b
) and make sure the revert makes it into 2.6.37?  We definitely don't
want to ship 2.6.37 with this patch in its current state.

-- Maciej
