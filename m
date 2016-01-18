From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Mon, 18 Jan 2016 08:53:13 -0800
Message-ID: <1453135993.1223.230.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160115142223.1e92be75@redhat.com>
	 <20160115.154721.458450438918273509.davem@davemloft.net>
	 <20160118112703.6eac71ca@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	borkmann@iogearbox.net, marek@cloudflare.com,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	john.r.fastabend@intel.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34469 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755750AbcARQxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 11:53:16 -0500
Received: by mail-pa0-f49.google.com with SMTP id uo6so422370996pac.1
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 08:53:16 -0800 (PST)
In-Reply-To: <20160118112703.6eac71ca@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-01-18 at 11:27 +0100, Jesper Dangaard Brouer wrote:

> The NAPI drivers actually already have a flush API (calling
> napi_complete_done()), BUT it does not always get invoked, e.g. if the
> driver have more work to do, and want to keep polling.
>  I'm not sure we want to delay "flushing" packets queued in the GRO
> layer for this long(?).

Since linux-3.7 we have this logic :

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=2e71a6f8084e7ac87166dd77d99c44190fb844fc


(Some arches have quite expensive high resolution timestamps)
