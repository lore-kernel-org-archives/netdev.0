From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 15 May 2012 19:23:59 +0200
Message-ID: <1337102639.8512.1117.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47696 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966003Ab2EORYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 13:24:05 -0400
Received: by bkcji2 with SMTP id ji2so5034899bkc.19
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 10:24:04 -0700 (PDT)
In-Reply-To: <1337101280.8512.1108.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 19:01 +0200, Eric Dumazet wrote:

> 
> napi_get_frags() could probably updated in net-next to use the first
> frag as skb->head to save 512 bytes per skb.

By the way GRO_MAX_HEAD definition is way too big, napi_get_frags()
allocates fat skbs (1280 bytes of overhead instead of 768 bytes)

This should be enough :

#define GRO_MAX_HEAD 128
