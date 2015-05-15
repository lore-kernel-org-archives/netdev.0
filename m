From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Fri, 15 May 2015 07:52:37 -0700
Message-ID: <1431701557.27831.103.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
	 <1431401204-731380-6-git-send-email-tom@herbertland.com>
	 <1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431406237.566.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
	 <1431446777.566.87.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150515143506.GA5019@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36430 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932526AbbEOOwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 10:52:38 -0400
Received: by iepk2 with SMTP id k2so114820781iep.3
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 07:52:38 -0700 (PDT)
In-Reply-To: <20150515143506.GA5019@via.ecp.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 16:35 +0200, Sabrina Dubroca wrote:
> Hi Eric,
> 
> 2015-05-15, 05:48:07 -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > First one in __skb_checksum_validate_complete() fixes the following
> > (and other callers)
> > 
> > make C=2 CF=-D__CHECK_ENDIAN__ net/ipv4/tcp_ipv4.o
> >   CHECK   net/ipv4/tcp_ipv4.c
> > include/linux/skbuff.h:3052:24: warning: incorrect type in return expression (different base types)
> > include/linux/skbuff.h:3052:24:    expected restricted __sum16
> > include/linux/skbuff.h:3052:24:    got int
> > 
> > Second is fixing gso_make_checksum() :
> > 
> >   CHECK   net/ipv4/gre_offload.c
> > include/linux/skbuff.h:3360:14: warning: incorrect type in assignment (different base types)
> > include/linux/skbuff.h:3360:14:    expected unsigned short [unsigned] [usertype] csum
> > include/linux/skbuff.h:3360:14:    got restricted __sum16
> > include/linux/skbuff.h:3365:16: warning: incorrect type in return expression (different base types)
> > include/linux/skbuff.h:3365:16:    expected restricted __sum16
> > include/linux/skbuff.h:3365:16:    got unsigned short [unsigned] [usertype] csum
> > 
> > 
> > Fixes: 5a21232983aa7 ("net: Support for csum_bad in skbuff")
> > Fixes: 7e2b10c1e52ca ("net: Support for multiple checksums with gso")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > CC: Tom Herbert <tom@herbertland.com>
> > ---
> 
> That's very similar to what I submitted in February:
> https://patchwork.ozlabs.org/patch/437332/

Well, given you did not address David concerns, and Tom apparently does
not know how to use sparse, I finally gave up.
