From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Double free of dst_entry in ipv4_dst_destroy()
Date: Fri, 11 Dec 2015 07:48:33 -0800
Message-ID: <1449848913.9768.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151206132657.Horde.rQvtH4bu51mT83V1RAKxWA1@ltc.linux.ibm.com>
	 <1449435784.25029.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449453515.25029.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1449843809.9768.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, predeep@us.ibm.com, mjtarsel@us.ibm.com
To: dwilder@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35758 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761AbbLKPsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 10:48:39 -0500
Received: by pfd5 with SMTP id 5so6308129pfd.2
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 07:48:36 -0800 (PST)
In-Reply-To: <1449843809.9768.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-12-11 at 06:23 -0800, Eric Dumazet wrote:
> On Sun, 2015-12-06 at 17:58 -0800, Eric Dumazet wrote:
> > On Sun, 2015-12-06 at 13:03 -0800, Eric Dumazet wrote:
> > 
> > > But then when later we promote a skb->dst to a refctounted one
> > > (skb_dst_force(), we might make sure we abort the operation if __refcnt
> > > == 0 ( and DST_NOCACHE is in dst->flags)
> > > 
> > 
> > Minimum patch would be :
> > 
> 
> Here is a more complete patch, it should fix the issue I think :

Hmm, I'll send a v3, I forgot to test DST_NOCACHE properly.
