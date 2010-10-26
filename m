From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] qlcnic: dma address align check
Date: Tue, 26 Oct 2010 12:30:33 +0200
Message-ID: <1288089033.3169.73.camel@edumazet-laptop>
References: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
	 <1288085882-11988-5-git-send-email-amit.salecha@qlogic.com>
	 <1288086894.3169.53.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F871A817A@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62702 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755727Ab0JZKan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 06:30:43 -0400
Received: by wwe15 with SMTP id 15so4575933wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 03:30:42 -0700 (PDT)
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F871A817A@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 05:04 -0500, Amit Salecha a =C3=A9crit =
:

> Is it ? I am not aware about such calculation.

Yes it is

> Is pci_alloc_consistent guarantee to give PAGE align dma address ?

I believe so

By the way, you should use dma_alloc_coherent() instead of
pci_alloc_consistent() so that you can use GFP_KERNEL allocations
instead of GFP_ATOMIC, it might help in low memory conditions (if you
dont hold a spinlock at this point)


If TX_DESC_RINGSIZE(tx_ring) is not a power of two, then yes you could
probably add 64 bytes and avoid allocating a full page only for the u32
field ;)



