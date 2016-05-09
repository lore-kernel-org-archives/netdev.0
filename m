From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH V1 3/3] net: warn on napi_alloc_skb being called
 in wrong context
Date: Mon, 9 May 2016 16:53:41 +0300
Message-ID: <b9f06970-686d-e04d-7620-94e085238456@cogentembedded.com>
References: <20160509134352.3573.37044.stgit@firesoul>
 <20160509134439.3573.97841.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, gerlitz.or@gmail.com, eugenia@mellanox.com,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:33816 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbcEINxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 09:53:49 -0400
Received: by mail-lf0-f51.google.com with SMTP id m64so200487454lfd.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 06:53:48 -0700 (PDT)
In-Reply-To: <20160509134439.3573.97841.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/9/2016 4:44 PM, Jesper Dangaard Brouer wrote:

> It have always been required to call napi_alloc_skb from NAPI/softirq

    It has.

> context, which implies running with local_bh_disable'ed.  Thus, this

    Not local_bh_disable'd?

> code path should already be well tested. But recent SKB bulk changes
> introduced will make this more volatile and bugs more subtle, if this
> is violated.
>
> To catch any driver violating this add a loud WARN_ON.
>
> Performance wise, I do worry about adding this runtime check code into
> the hotpath, of this highly optimized function call.  I've

    Hot path? My spellchecked trips here.

> micro-benchmarked it with both IP-forwarding and local UDP delivery,
> and didn't see any regressions.  It does adds extra code size (icache).
>
> add/remove: 0/0 grow/shrink: 1/0 up/down: 43/0 (43)
> function                                     old     new   delta
> __napi_alloc_skb                             461     504     +43
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
[...]

MBR, Sergei
