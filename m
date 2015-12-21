From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH v2] ip{,6}tunnel: have a shared stats parser/printer
Date: Mon, 21 Dec 2015 12:00:06 +0100
Message-ID: <5677DBB6.3070008@iogearbox.net>
References: <20151218105225.GA19288@orbyte.nwl.cc> <1450436286-14882-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49852 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbbLULAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 06:00:12 -0500
In-Reply-To: <1450436286-14882-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2015 11:58 AM, Phil Sutter wrote:
> This has a slight side-effect of not aborting when /proc/net/dev is
> malformed, but OTOH stats are not parsed for uninteresting interfaces=
=2E
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v1:
> - Fix conflict resolution (sscan from 'buf' instead of 'ptr').
[...]

Hmm, did you actually compile that?

The code is still the same as in v1 ... the only thing added is the "Ch=
anges since v1"
description. ;)

[...]
> +void tnl_print_stats(const char *buf)
> +{
> +	unsigned long rx_bytes, rx_packets, rx_errs, rx_drops,
> +		      rx_fifo, rx_frame,
> +		      tx_bytes, tx_packets, tx_errs, tx_drops,
> +		      tx_fifo, tx_colls, tx_carrier, rx_multi;
> +
> +	if (sscanf(ptr, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",

   s/ptr/buf/

> +	           &rx_bytes, &rx_packets, &rx_errs, &rx_drops,
> +	           &rx_fifo, &rx_frame, &rx_multi,
> +	           &tx_bytes, &tx_packets, &tx_errs, &tx_drops,
> +	           &tx_fifo, &tx_colls, &tx_carrier) !=3D 14)
> +		return;
> +
> +	printf("%s", _SL_);
> +	printf("RX: Packets    Bytes        Errors CsumErrs OutOfSeq Mcasts=
%s", _SL_);
> +	printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-8ld%s",
> +	       rx_packets, rx_bytes, rx_errs, rx_frame, rx_fifo, rx_multi, =
_SL_);
> +	printf("TX: Packets    Bytes        Errors DeadLoop NoRoute  NoBufs=
%s", _SL_);
> +	printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-6ld",
> +	       tx_packets, tx_bytes, tx_errs, tx_colls, tx_carrier, tx_drop=
s);
> +}

tunnel.c: In function =91tnl_print_stats=92:
tunnel.c:211:13: error: =91buff=92 undeclared (first use in this functi=
on)
   if (sscanf(buff, "%lu%lu%lu%lu%lu%lu%lu%*d%lu%lu%lu%lu%lu%lu%lu",
              ^
tunnel.c:211:13: note: each undeclared identifier is reported only once=
 for each function it appears in
make[1]: *** [tunnel.o] Error 1
make[1]: *** Waiting for unfinished jobs....
make: *** [all] Error 2
