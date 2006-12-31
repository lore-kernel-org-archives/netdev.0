From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core/flow.c: compare data with memcmp
Date: Sun, 31 Dec 2006 12:37:15 -0800 (PST)
Message-ID: <20061231.123715.115911390.davem@davemloft.net>
References: <80ec54e90612310837y786fd764oc18bf37c8f0b2b8c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933211AbWLaUhQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Dec 2006 15:37:16 -0500
To: daniel.marjamaki@gmail.com
In-Reply-To: <80ec54e90612310837y786fd764oc18bf37c8f0b2b8c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Daniel_Marjam=E4ki" <daniel.marjamaki@gmail.com>
Date: Sun, 31 Dec 2006 17:37:05 +0100

> From: Daniel Marjam=E4ki
> This has been tested by me.
> Signed-off-by: Daniel Marjam=E4ki <daniel.marjamaki@gmail.com>

Please do not do this.

memcmp() cannot assume the alignment of the source and
destination buffers and thus will run more slowly than
that open-coded comparison.

That code was done like that on purpose because it is
one of the most critical paths in the networking flow
cache lookup which runs for every IPSEC packet going
throught the system.
