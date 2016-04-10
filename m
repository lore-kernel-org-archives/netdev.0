From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: optimizations to sk_buff handling in rds_tcp_data_ready
Date: Sun, 10 Apr 2016 16:54:40 -0700
Message-ID: <1460332480.6473.536.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160407130859.GA2818@oracle.com>
	 <1460038560.6473.397.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160410001853.GA30364@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34351 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbcDJXyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 19:54:44 -0400
Received: by mail-qg0-f44.google.com with SMTP id c6so131949718qga.1
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 16:54:43 -0700 (PDT)
In-Reply-To: <20160410001853.GA30364@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-09 at 20:18 -0400, Sowmini Varadhan wrote:
> On (04/07/16 07:16), Eric Dumazet wrote:
> > Use skb split like TCP in output path ?
> > Really, pskb_expand_head() is not supposed to copy payload ;)
> 
> Question- how come skb_split doesnt have to deal with frag_list
> and do a skb_walk_frags()? Couldn't the split-line be somewhere
> in the frag_list? Also even for the skb_split_inside_header,
> dont we have to set
>   skb_shinfo(skb1)->frag_list = skb_shinfo(skb)->frag_list;
> and cut loose the skb_shinfo(skb)->frag_list?
> 
> As I try to mimic skb_split in some new set of "skb_carve"
> funtions, I'm running into all  the various frag_list cases. I'm 
> afraid I might end up needing most of the stuff under the "Pure 
> masohism" (sic) comment in __pskb_pull_tail(). 
> 

The helper was written for TCP I guess. TCP in output path never uses
skb_shinfo(skb)->frag_list : It is guaranteed to be NULL for all skbs.
