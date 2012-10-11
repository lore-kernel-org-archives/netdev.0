From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Thu, 11 Oct 2012 12:05:24 +0200
Message-ID: <1349949924.21172.8462.camel@edumazet-glaptop>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349792241.21847.199.camel@zakaz.uk.xensource.com>
	 <1349792847.21172.4479.camel@edumazet-glaptop>
	 <1349793630.21847.208.camel@zakaz.uk.xensource.com>
	 <1349863984.10070.26.camel@zakaz.uk.xensource.com>
	 <1349874598.10070.39.camel@zakaz.uk.xensource.com>
	 <748966751.20121010164949@eikelenboom.it>
	 <1349942546.14806.7.camel@zakaz.uk.xensource.com>
	 <151954917.20121011120004@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	xen-devel <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43478 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab2JKKF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 06:05:27 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so852128bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 03:05:26 -0700 (PDT)
In-Reply-To: <151954917.20121011120004@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 12:00 +0200, Sander Eikelenboom wrote:

> Probably due to the BUG_ON from the patch below, i changed it into a WARN_ON.
> And i seem to hit it, but only in one of the guests at the moment and it triggers quite irregularly.

xennet_make_frags() is able to split the skb->head in multiple page-size
chunks.

It should do the same for fragments
