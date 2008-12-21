From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [PATCH] netlink: fix (theoretical) overrun in message iteration
Date: Sun, 21 Dec 2008 15:46:39 +0100
Message-ID: <19f34abd0812210646i70340ac1xe5489f5518484859@mail.gmail.com>
References: <20081221134218.GA7959@localhost.localdomain>
	 <19f34abd0812210644j6f11717bi84238d172feed8b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Thomas Graf" <tgraf@suug.ch>, "Eugene Teo" <eugeneteo@kernel.sg>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Al Viro" <viro@zeniv.linux.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:35989 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbYLUOqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 09:46:42 -0500
In-Reply-To: <19f34abd0812210644j6f11717bi84238d172feed8b6@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 21, 2008 at 3:44 PM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
> On Sun, Dec 21, 2008 at 2:42 PM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
>> From bb805d89e84ddb11c9bb58afcfd9a6b37bbe5a9b Mon Sep 17 00:00:00 2001
>> From: Vegard Nossum <vegard.nossum@gmail.com>
>> Date: Sun, 21 Dec 2008 14:20:49 +0100
>> Subject: [PATCH] netlink: fix (theoretical) overrun in message iteration
>>
>> See commit 1045b03e07d85f3545118510a587035536030c1c for a detailed
>> explanation of why this patch is necessary.
>>
>> In short, nlmsg_next() can make "remaining" go negative, and the
>> remaining >= sizeof(...) comparison will promote "remaining" to an
>> unsigned type, which means that the expression will evaluate to
>> true for negative numbers, even though it was not intended.
>>
>> I put "theoretical" in the title because I have no evidence that
>> this can actually happen, but I suspect that a crafted netlink
>> packet can trigger some badness.
>
> nlmsg

Oops. I meant to say that nlmsg_for_each_msg() has no users at all,
which means that the change is all the more "theoretical" :-)


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
