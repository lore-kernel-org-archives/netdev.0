From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Wed, 27 Aug 2008 19:56:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808271948000.4539@wrl-59.cs.helsinki.fi>
References: <48B5815D.4010005@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46232 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbYH0Q4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 12:56:11 -0400
In-Reply-To: <48B5815D.4010005@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008, Pavel Emelyanov wrote:

> After turning IP_XXX_STATS, TCP_XXX_STATS and NET_XXX_STATS from
> macros into functions the net/ipv4/built-in.o shrank significantly:
> 
> add/remove: 14/0 grow/shrink: 0/67 up/down: 482/-2246 (-1764)
> 
> Turning the CONFIG_NET_NS option on makes this shrink even larger:
> 
> add/remove: 14/0 grow/shrink: 0/67 up/down: 478/-2646 (-2168)

Is there perhaps some DEBUG related config that could bloat these numbers?
...I didn't come up with anything obvious when I quickly looked the 
definations but I might have missed something.

> So the question is - what was the reason to keep those as macros?
> I thought about the possible performance questions, but netperf
> didn't show any (I admit I just cannot cook it properly).

IMHO, even if there would be some performance regression, only the
most hottest paths would need to have it inlined, the rest would be
quite fine having it as a function.

--
 i.
