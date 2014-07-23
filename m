From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next 05/10] net: Add Geneve tunneling protocol driver
Date: Wed, 23 Jul 2014 11:20:12 -0700
Message-ID: <20140723112012.0bf89a0f@haswell>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-6-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:56815 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932241AbaGWSUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 14:20:10 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so2091216pdj.29
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 11:20:10 -0700 (PDT)
In-Reply-To: <1406024393-6778-6-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jul 2014 03:19:48 -0700
Andy Zhou <azhou@nicira.com> wrote:

> +	geneveh->ver = GENEVE_VER;
> +	geneveh->opt_len = options_len / 4;
> +	geneveh->oam = !!(tun_flags & TUNNEL_OAM);
> +	geneveh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
> +	geneveh->rsvd1 = 0;

Bitfield's suck in C.

Setting bitfield values individually generates slow code because
the compiler has to generate multiple mask operations.

Better to change this part to one set of shifts and do one load.
