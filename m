From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan gso is broken by stackable gso_segment()
Date: Fri, 25 Oct 2013 16:25:02 -0700
Message-ID: <1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:51086 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541Ab3JYXZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:25:07 -0400
Received: by mail-ea0-f180.google.com with SMTP id l9so816784eaj.25
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 16:25:05 -0700 (PDT)
In-Reply-To: <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 15:41 -0700, Alexei Starovoitov wrote:

> 'bool tunnel' actually still used to indicate encap_level > 0
> 

Yes, I am studying if the setting of skb->encapsulation = 1 was really
needed in the :

if (tunnel) {
     skb_reset_inner_headers(skb);
     skb->encapsulation = 1;
}

And was planning to rename 'bool tunnel' by 'bool stacked' or
something... 

> Eric's fix brings back performance for vxlan and gre keeps working. Thx!

Please note the original performance is not that good, you mentioned 230
Mbps on lxc, while I get more than 5Gb/s on a 10G link.

This should be investigated ...

> 
> net/core/skbuff.c:3474 skb_try_coalesce() warning, I mentioned before,
> is unrelated.
> I still see it with this patch. Running either gre or vxlan tunnels.

I think this might be related to commit 6ff50cd55545 ("tcp: gso: do not
generate out of order packets")

I'll investigate this as well, thanks.
