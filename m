From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 unique local address flushes on up/down
Date: Wed, 26 Mar 2008 00:24:28 +0900 (JST)
Message-ID: <20080326.002428.19095257.yoshfuji@linux-ipv6.org>
References: <200803251557.21563.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hostap@lists.shmoo.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: chunkeey@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54994 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754901AbYCYPXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 11:23:03 -0400
In-Reply-To: <200803251557.21563.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <200803251557.21563.chunkeey@web.de> (at Tue, 25 Mar 2008 15:57:21 +0100), Chr <chunkeey@web.de> says:

> Now my question, which _one_ should we fix the applications or the stack?!
> I think the network stack, but I don't know if there are RFC about this 
> issue... or is there already some flag/setting which I've missed so far?  

Well..., in fact, this is known as an uneasy-to-fix issue.
The behavior han not been changed for long time, so you definately
need to have work-around for this issue, anyway.

>From specification point of view, we need to re-perform DAD (duplicate
address detection) after down-up cycle or even link-down and up.
One possible way is to add "tentative" flag for static addresses
(instead of purging them) when the interface is going down and
reperform DAD for all of such addresses when the interface is coming up.
If the link is being down, we might want to use "Optimistic" DAD instead.

--yoshfuji
