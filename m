From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Thu, 01 May 2014 10:46:30 -0700
Message-ID: <1398966390.29914.203.camel@edumazet-glaptop2.roam.corp.google.com>
References: <395225650.20140430124506@eikelenboom.it>
	 <536162D3.5080307@citrix.com> <94755525.20140501002553@eikelenboom.it>
	 <53624E25.8040404@citrix.com> <1810270947.20140501155911@eikelenboom.it>
	 <53626C39.3030304@citrix.com> <928229683.20140501193936@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	xen-devel@lists.xen.org
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:58816 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbaEARqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 13:46:32 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so3986915pad.1
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 10:46:32 -0700 (PDT)
In-Reply-To: <928229683.20140501193936@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 19:39 +0200, Sander Eikelenboom wrote:

> Will run that for both the cases:
>         skb->truesize -= skb->data_len;
>         skb->truesize -= nskb->data_len;
> 
> Let's see what that does different and if that gives an insight in what is going 
> wrong.


Playing with skb->truesize only makes TCP stack reacts faster to bloat,
calling tcp collapse to save memory.

So you might prevent the bug from happening, not really fix root cause.
