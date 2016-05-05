From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: A couple of questions about the SKB fragments
Date: Thu, 5 May 2016 08:58:29 -0400
Message-ID: <20160505125829.GA26978@oracle.com>
References: <CAKh5naYrZtf5y_Qw93G+GbxRVucsk4nbuiaguHcghtKEL=yQBw@mail.gmail.com>
 <572B2AEE.1020802@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matvejchikov@gmail.com, netdev@vger.kernel.org,
	Aleksey.Baulin@gmail.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31159 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbcEEM6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 08:58:45 -0400
Content-Disposition: inline
In-Reply-To: <572B2AEE.1020802@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (05/05/16 12:13), Edward Cree wrote:
> On 05/05/16 08:40, Ilya Matveychikov wrote:
> >
> > While working with fragmented SKBs we've got stuck with the following:
> > - is it possible for an SKB fragment in skb_shinfo(skb)->frag_list to
> > be fragmented too (i.e. to have SKBs in frag_list)?
> > - do skb->len and skb->data_len contain the whole SKB length,
> > including the length of all fragments (not only the paged parts)?
> >
> > Is there any docs except the kernel sources itself to refer to?
> davem has some docs up at http://vger.kernel.org/~davem/skb.html and
> http://vger.kernel.org/~davem/skb_data.html
> In particular note the following:
> "The frag_list is used to maintain a chain of SKBs organized for
>  fragmentation purposes, it is _not_ used for maintaining paged data."
> So my reading would suggest there is no way to multiple-layer-fragment
> an SKB; the frags are page pointers and offsets, not entire sk_buff
> structs in their own right.

Actually (and perhaps I am mixing up skb_frag_t with the sk_buff in
skb_shinfo(skb)->frag_list) I think it is entirely possible in theory 
for the frag_list to itself both skb_frag_t's as well as more sk_buffs
in the ->frag_list- at least that's why I understand fromcode
that recurses using skb_walk_frags(), such as tcp_md5_hash_skb_data().
AIUI, the statement about page pointers and offsets applies to the 
skb_frag_t's in the skb_shared_info. The len and data_len should be
the sum-total for the whole skb, including skb_frag_t's and ->frag_list.

--Sowmini
