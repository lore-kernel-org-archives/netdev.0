From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BQL support in gianfar causes network hickup
Date: Tue, 27 Nov 2012 05:32:42 -0800
Message-ID: <1354023162.7553.1708.camel@edumazet-glaptop>
References: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6E@Exchange1.lawo.de>
	 <50AFA599.9040108@windriver.com> <loom.20121124T213422-650@post.gmane.org>
	 <1353800616.2590.4562.camel@edumazet-glaptop>
	 <20121126100111.GA3728@mac.home> <1353947677.7553.2.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE6F@Exchange1.lawo.de>
	 <1353950255.7553.6.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE70@Exchange1.lawo.de>
	 <1354019816.7553.1585.camel@edumazet-glaptop>
	 <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE71@Exchange1.lawo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tino Keitel <tino.keitel@tikei.de>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keitel, Tino (ALC NetworX GmbH)" <Tino.Keitel@alcnetworx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:62332 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771Ab2K0Ncp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 08:32:45 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so8160617iea.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 05:32:45 -0800 (PST)
In-Reply-To: <9AA65D849A88EB44B5D9B6A8BA098E23040A60D6EE71@Exchange1.lawo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 13:42 +0100, Keitel, Tino (ALC NetworX GmbH)
wrote:
> On Di, 2012-11-27 at 04:36 -0800, Eric Dumazet wrote:
> > 
> > Can you reproduce the problem using a single cpu ?
> 
> Yes, it is a single-CPU system.

Can you reproduce the problem without PTP running, or disabled in the
driver ?

(comment the "priv->hwts_tx_en = 1;" line)


This looks like we miss an interrupt ( or TXBD_INTERRUPT not correctly
set)

And it could be a bug occurring if we try to send one skb with fragments
and skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP 
