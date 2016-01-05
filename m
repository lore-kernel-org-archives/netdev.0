From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] soreuseport: change consume_skb to kfree_skb
 in error case
Date: Tue, 05 Jan 2016 11:34:40 -0800
Message-ID: <1452022480.8255.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452009433-22171-1-git-send-email-kraigatgoog@gmail.com>
	 <1452015516.8255.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEfhGiyu0iRJcnOUiippoOtRZzUwoSihGVb3240G9hBSh0t5bw@mail.gmail.com>
	 <1452018666.8255.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEfhGiym3O8PaZdbReHHRQ1Cnq2OuOQfmbjSf2x1bTyqvdNPuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34975 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbcAETem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 14:34:42 -0500
Received: by mail-pa0-f44.google.com with SMTP id do7so1083100pab.2
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 11:34:41 -0800 (PST)
In-Reply-To: <CAEfhGiym3O8PaZdbReHHRQ1Cnq2OuOQfmbjSf2x1bTyqvdNPuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 14:12 -0500, Craig Gallek wrote:

> OK, I can buy that an skb should be piped through udp4|6_lib_lookup2,
> but I don't think it's safe to remove the skb NULL check in
> reuseport_select_sock.  There's at least one path (udp_diag.c:
> udp_dump_one) which does a lookup without an skb.  I'll start with
> your patch in a separate thread and we can discuss outside the context
> of the kfree_skb change.

Well, udp_dump_one() is broken vs SO_REUSEPORT. Fortunately iproute2
does not use it (yet)

We need to to get the socket designated by req->id.idiag_cookie,
ie ignoring reusport hash or BPF completely.
