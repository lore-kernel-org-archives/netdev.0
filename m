From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do we use RX queue mapping for TX?
Date: Fri, 20 Feb 2015 11:08:07 -0800
Message-ID: <1424459287.5565.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
	 <CAHA+R7PdG+jDqFA1jDFzHtkrxqLEZdtj1w5QyrdYMO4fX6+A1w@mail.gmail.com>
	 <CAHA+R7OVHgwQBM200UZDKiw5eypuzhWj=B4E3MRkOK3yViZDCQ@mail.gmail.com>
	 <1424301248.4942.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7PbLRw-oA4v9ivZ0s-++ALx99zddJLDqDoemyBTc2XZ1g@mail.gmail.com>
	 <1424304992.4942.109.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7N=uFyja4daQTY50RVMAzYT1J1AUMmsF+6HynZQED+OgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:40795 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312AbbBTTIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 14:08:09 -0500
Received: by iebtr6 with SMTP id tr6so10120556ieb.7
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 11:08:09 -0800 (PST)
In-Reply-To: <CAHA+R7N=uFyja4daQTY50RVMAzYT1J1AUMmsF+6HynZQED+OgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-20 at 10:09 -0800, Cong Wang wrote:

> Yes of course, but that means I need an indirect layer to
> map RX to TX (ifb or mirred), since I only care about TX queues. :-/

We do care of TX queues as well, but we use XPS, for performance
reasons.

It looks like you want something very different.

Note : netdev_pick_tx/ndo_select_queue() is called before queue
selection.

Maybe you want something close to the reclassify thing in tc, allowing
a packet to restart the tx _before_ the point netdev_pick_tx() is
called.
