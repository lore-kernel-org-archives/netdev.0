From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Mon, 04 Apr 2016 07:33:40 -0700
Message-ID: <1459780420.6473.337.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	 <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
	 <57022A85.6040002@iogearbox.net> <20160404150700.1456ae80@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, gerlitz@mellanox.com,
	john.fastabend@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:36081 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755978AbcDDOdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 10:33:47 -0400
Received: by mail-vk0-f42.google.com with SMTP id c4so56547164vkb.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 07:33:47 -0700 (PDT)
In-Reply-To: <20160404150700.1456ae80@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-04 at 15:07 +0200, Jesper Dangaard Brouer wrote:

> Argh... maybe the minimal pseudo/fake SKB is the wrong "signal" to send
> to users of this API.
> 
> The hole idea is that an SKB is NOT allocated yet, and not needed at
> this level.  If we start supporting calling underlying SKB functions,
> then we will end-up in the same place (performance wise).

A BPF program can access many skb fields.

If you plan to support BPF, your fake skb needs to be populated like a
real one. Looks like some code will be replicated in all drivers that
want this facility...

Or accept (document ?) that some BPF instructions are just not there.
(hash, queue_mapping ...)
