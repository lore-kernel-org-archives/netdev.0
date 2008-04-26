From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Sat, 26 Apr 2008 14:09:38 +0900 (JST)
Message-ID: <20080426.140938.99042118.yoshfuji@linux-ipv6.org>
References: <20080426.123359.14563419.yoshfuji@linux-ipv6.org>
	<OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33769 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbYDZFJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 01:09:41 -0400
In-Reply-To: <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OF326F3AF9.7322F5FB-ON88257437.00174874-88257437.00194F7B@us.ibm.com> (at Fri, 25 Apr 2008 21:36:29 -0700), David Stevens <dlstevens@us.ibm.com> says:

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
>         In this case, we want no pad, so packed is the relevant part. If
> had a char followed by a struct as in your previous example, the right
> way to get 4-byte alignment is both aligned(4) and packed. Leaving off
> packed would allow 8-byte or 16-byte (or 12 :-)) alignment, too.

__compat_sockaddr_storage{} is intended for defining **self-containing**
sockaddr_stroage{} aligned like 32bit archs - aligned(4).

Even your code - sockaddr_storage{} might be aligned on 64bit even on
32bit archs.  If the alignment rules of 32bit were different between
32bit and 64bit, most (if not all) compat layers must have been changed.
See?

The attribute((packed)) is overkill and evil.  Please remove that.
Per-member attribute is ugly and the definition is not self-contained.
So, please define __compat_sockaddr_storage{}.

--yoshfuji
