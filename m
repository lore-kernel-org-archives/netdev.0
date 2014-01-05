From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Sun, 5 Jan 2014 12:00:39 +0800
Message-ID: <CAPshTCi0KEAysZZcstj7eFcoGTG5aSH=KrNNMb0BhdqfxF7qMw@mail.gmail.com>
References: <1388813047-5262-1-git-send-email-hkchu@google.com>
	<20140104.200931.524755895829922293.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:44327 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbaAEEAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 23:00:40 -0500
Received: by mail-qc0-f170.google.com with SMTP id x13so16679599qcv.1
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 20:00:39 -0800 (PST)
In-Reply-To: <20140104.200931.524755895829922293.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 5, 2014 at 9:09 AM, David Miller <davem@davemloft.net> wrote:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Fri,  3 Jan 2014 21:24:07 -0800
>
>> +struct packet_offload *gro_find_receive_by_type(__be16 type);
>> +struct packet_offload *gro_find_complete_by_type(__be16 type);
>
> You're not exporting these to modules, therefore if GRE is built
> modular it won't work.
>
> Please use GPL exports.

Aha, now I remember why i decided to export the symbols, the same
reason above. Also I thought in the future other encap protocol that is
not statically included might need to access the symbols.

But given Eric's point below these other encap protocol could always
place their GRO handler in separate files to be included statically. So
I'll include Eric's change below. Hope it makes sense.

Thanks,

Jerry
