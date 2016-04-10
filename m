From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: optimizations to sk_buff handling in rds_tcp_data_ready
Date: Sat, 9 Apr 2016 20:18:53 -0400
Message-ID: <20160410001853.GA30364@oracle.com>
References: <20160407130859.GA2818@oracle.com>
 <1460038560.6473.397.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38236 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbcDJATD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 20:19:03 -0400
Content-Disposition: inline
In-Reply-To: <1460038560.6473.397.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (04/07/16 07:16), Eric Dumazet wrote:
> Use skb split like TCP in output path ?
> Really, pskb_expand_head() is not supposed to copy payload ;)

Question- how come skb_split doesnt have to deal with frag_list
and do a skb_walk_frags()? Couldn't the split-line be somewhere
in the frag_list? Also even for the skb_split_inside_header,
dont we have to set
  skb_shinfo(skb1)->frag_list = skb_shinfo(skb)->frag_list;
and cut loose the skb_shinfo(skb)->frag_list?

As I try to mimic skb_split in some new set of "skb_carve"
funtions, I'm running into all  the various frag_list cases. I'm 
afraid I might end up needing most of the stuff under the "Pure 
masohism" (sic) comment in __pskb_pull_tail(). 

--Sowmini
