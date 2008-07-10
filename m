From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [PATCH v2] rc80211_pid: Fix fast_start parameter handling
Date: Thu, 10 Jul 2008 11:58:11 +0200
Message-ID: <19f34abd0807100258y1dfef681w7b293779fc1a12f4@mail.gmail.com>
References: <19f34abd0807070427w5398c617uae0a4e8e40fd8f0e@mail.gmail.com>
	 <1215464899.4416.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>,
	"Pekka Enberg" <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org
To: "Mattias Nissler" <mattias.nissler@gmx.de>,
	"Stefano Brivio" <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:50729 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbYGJJ6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 05:58:13 -0400
Received: by wf-out-1314.google.com with SMTP id 27so3201957wfd.4
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 02:58:11 -0700 (PDT)
In-Reply-To: <1215464899.4416.22.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 7, 2008 at 11:08 PM, Mattias Nissler <mattias.nissler@gmx.de> wrote:
> This removes the fast_start parameter from the rc_pid parameters information
> and instead uses the parameter macro when initializing the rc_pid state. Since
> the parameter is only used on initialization, there is no point of making
> exporting it via debugfs. This also fixes uninitialized memory references to
> the fast_start and norm_offset parameters detected by the kmemcheck utility.
> Thanks to Vegard Nossum for reporting the bug.
>
> Signed-off-by: Mattias Nissler <mattias.nissler@gmx.de>
> ---
>
> Updated patch description. Any more comments? Stefano? John?
>
> Mattias

Hi,

I've tested the patch now. This was my config:

CONFIG_MAC80211_RC_DEFAULT_PID=y
CONFIG_MAC80211_RC_PID=y

and I'm using b43 driver successfully:

CONFIG_B43=y
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_DEBUG=y

This works too:

# cat /debug/ieee80211/phy0/rc80211_pid/*
15
9
15
3
125
0
0
3
14

I guess you may put Tested-by: if this seems enough to verify that the
patch causes no other harm.

Can any of the net people acknowledge the reception of this patch? If
it doesn't make it for 2.6.26, we should at least Cc stable.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
