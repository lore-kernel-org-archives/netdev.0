From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 2 Dec 2011 15:54:12 +0100
Message-ID: <CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
References: <igorm@etf.rs>
	<1322831399-23505-1-git-send-email-igorm@etf.rs>
	<1322836191.2762.3.camel@edumazet-laptop>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:59322 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065Ab1LBOyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 09:54:18 -0500
Received: from localhost (avs2.etf.rs [147.91.14.173])
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id D9E7312014A
	for <netdev@vger.kernel.org>; Fri,  2 Dec 2011 15:54:16 +0100 (CET)
Received: from mx2.etf.bg.ac.rs ([147.91.14.170])
	by localhost (avs2.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id nOwf7RlD8-AP for <netdev@vger.kernel.org>;
	Fri,  2 Dec 2011 15:54:15 +0100 (CET)
Received: from mail-pz0-f46.google.com (mail-pz0-f46.google.com [209.85.210.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 1148A60145
	for <netdev@vger.kernel.org>; Fri,  2 Dec 2011 15:54:14 +0100 (CET)
Received: by dadv6 with SMTP id v6so1493463dad.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 06:54:12 -0800 (PST)
In-Reply-To: <1322836191.2762.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm... What about rtl8169_tx_clear_range() or rtl8169_tx_clear() ?
>

You mean we should put netdev_reset_queue() in those functions?

I think that we shouldn't put any thing in these functions.

When ever they are called, they are precede/followed by function
rtl8169_hw_reset() which calls rtl_hw_reset() which calls
rtl8169_init_ring_indexes() in which I've put netdev_reset_queue()

Only time when rtl8169_tx_clear_range() isn't preceded/followed by
rtl8169_hw_reset() is in function rtl8169_xmit_frags(). In that
function it's
called only in case there's an error. In case there was an error in that
function, netdev_sent_queue() will never be called, so we are going to have
accurate length of queue.
