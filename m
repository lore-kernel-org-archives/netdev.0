From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 01 Apr 2016 19:15:33 -0700
Message-ID: <1459563333.6473.302.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160402015709.GA19365@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:36062 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755338AbcDBCPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 22:15:36 -0400
Received: by mail-yw0-f169.google.com with SMTP id g3so195577645ywa.3
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 19:15:36 -0700 (PDT)
In-Reply-To: <20160402015709.GA19365@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-02 at 09:57 +0800, Herbert Xu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > I do not particularly care, but it is worth mentioning that GRO+TSO
> > would not be idempotent anymore.
> 
> We could easily fix that by adding a feature bit to control this,
> something like SKB_GSO_TCP_FIXEDID.

I understood the patch allowed to aggregate 4 segments having

ID=12   ID=40   ID=80  ID=1000

-> resulting GRO packet with 4 segments and ID=12.  TSO would generate
12,13,14,15   or 12,12,12,12 with your flag ?

(Before the patch no aggregation took place and exact same packets were
forwarded with 12, 40, 80, 1000)

As I said, I am not sure we should care :)
