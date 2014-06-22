From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable] net: huawei_cdc_ncm: increase command
 buffer size
Date: Sat, 21 Jun 2014 19:34:04 -0700 (PDT)
Message-ID: <20140621.193404.1524985182957166239.davem@davemloft.net>
References: <1403094084-13588-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	mrkiko.rs@gmail.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbaFVCeF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 22:34:05 -0400
In-Reply-To: <1403094084-13588-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 18 Jun 2014 14:21:24 +0200

> Messages from the modem exceeding 256 bytes cause communication
> failure.
>=20
> The WDM protocol is strictly "read on demand", meaning that we only
> poll for unread data after receiving a notification from the modem.
> Since we have no way to know how much data the modem has to send,
> we must make sure that the buffer we provide is "big enough".
> Message truncation does not work. Truncated messages are left unread
> until the modem has another message to send.  Which often won't
> happen until the userspace application has given up waiting for the
> final part of the last message, and therefore sends another command.
>=20
> With a proper CDC WDM function there is a descriptor telling us
> which buffer size the modem uses. But with this vendor specific
> implementation there is no known way to calculate the exact "big
> enough" number.  It is an unknown property of the modem firmware.
> Experience has shown that 256 is too small.  The discussion of
> this failure ended up concluding that 512 might be too small as
> well. So 1024 seems like a reasonable value for now.
>=20
> Fixes: 41c47d8cfd68 ("net: huawei_cdc_ncm: Introduce the huawei_cdc_n=
cm driver")
> Cc: Enrico Mioso <mrkiko.rs@gmail.com>
> Reported-by: Dan Williams <dcbw@redhat.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied and queued up for -stable, thanks!
