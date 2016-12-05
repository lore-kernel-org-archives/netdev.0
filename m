From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: [patch net v3] net: fec: fix compile with CONFIG_M5272
Date: Mon, 5 Dec 2016 21:06:41 +0300
Message-ID: <fe66d23d-345a-a87a-cbaa-270b1ebdb315@cogentembedded.com>
References: <1480959661-29834-1-git-send-email-nikita.yoush@cogentembedded.com>
 <CAMJBoFNd==OugwCjwT-q1MkooFr+Ed7AF00ifdimTk_DFVJO9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        linux-kernel@vger.kernel.org, Chris Healy <cphealy@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Fugang Duan <fugang.duan@nxp.com>,
        Eric Nelson <eric@nelint.com>, Andrew Lunn <andrew@lunn.ch>,
        Fabio Estevam <fabio.estevam@nxp.com>, netdev@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: Vitaly Wool <vitalywool@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:36026 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbcLESGq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:06:46 -0500
Received: by mail-lf0-f52.google.com with SMTP id t196so228484573lff.3
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 10:06:45 -0800 (PST)
In-Reply-To: <CAMJBoFNd==OugwCjwT-q1MkooFr+Ed7AF00ifdimTk_DFVJO9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>     +#define FEC_STATS_SIZE         (ARRAY_SIZE(fec_stats) * sizeof(u64))
> 
> 
> Do I take it right this actually translates to (sizeof(fec_stats) /
> sizeof(u64) * sizeof(u64))?

No.

fec_stats is an array of structs, each struct has car arrsy and integer,
and size of that is definitely not bytes.


ARRAY_SIZE(fec_stats) is number of stats, i.e. it is returned from
fec_enet_get_sset_count()

Each stat in blob is u64. Thus (ARRAY_SIZE(fec_stats) * sizeof(u64)) is
size of stats blob.
