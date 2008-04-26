From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 22:31:30 -0700 (PDT)
Message-ID: <20080425.223130.04936392.davem@davemloft.net>
References: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
	<OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751644AbYDZFbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 01:31:31 -0400
In-Reply-To: <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Fri, 25 Apr 2008 21:36:29 -0700

> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 04/25/2008 
> 08:33:59 PM:
> 
> > Please define __compat_sockaddr_storage{} with attribute((aligned(4))).
> > If you do that we do not need attribute(packed).  No?
> 
>         I just tried it and the compiler seems to do that for this case,
> but the gcc documentation says explicitly that you need both packed and
> aligned if you want it to be a specific value. aligned(4) is a minimum
> only and the compiler would be free to add pad still as long as the
> padded value was also 4-byte aligned.

Regardless, using packed has several other side effects you absolutely
do not want.  It causes words to be loaded using byte loads on RISC
architectures, because no alignment assumptions can be made at all
about packed objects.

Please use aligned(4), it should be totally sufficient.

>         In this case, we want no pad, so packed is the relevant part. If
> had a char followed by a struct as in your previous example, the right
> way to get 4-byte alignment is both aligned(4) and packed. Leaving off
> packed would allow 8-byte or 16-byte (or 12 :-)) alignment, too.

Have you seen this in practice?

>         I don't understand this comment. If you're suggesting I
> put these in an include file, I didn't because this is the only
> file that uses them and I don't want them to be visible to any
> other code. If you mean something else, please explain.

Right.
