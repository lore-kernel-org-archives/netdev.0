From: Edward Cree <ecree@solarflare.com>
Subject: Re: A couple of questions about the SKB fragments
Date: Thu, 5 May 2016 12:13:50 +0100
Message-ID: <572B2AEE.1020802@solarflare.com>
References: <CAKh5naYrZtf5y_Qw93G+GbxRVucsk4nbuiaguHcghtKEL=yQBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <Aleksey.Baulin@gmail.com>
To: <matvejchikov@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:13652 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752597AbcEELOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 07:14:43 -0400
In-Reply-To: <CAKh5naYrZtf5y_Qw93G+GbxRVucsk4nbuiaguHcghtKEL=yQBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/16 08:40, Ilya Matveychikov wrote:
> Hello folks,
>
> While working with fragmented SKBs we've got stuck with the following:
> - is it possible for an SKB fragment in skb_shinfo(skb)->frag_list to
> be fragmented too (i.e. to have SKBs in frag_list)?
> - do skb->len and skb->data_len contain the whole SKB length,
> including the length of all fragments (not only the paged parts)?
>
> Is there any docs except the kernel sources itself to refer to?
davem has some docs up at http://vger.kernel.org/~davem/skb.html and
http://vger.kernel.org/~davem/skb_data.html
In particular note the following:
"The frag_list is used to maintain a chain of SKBs organized for
 fragmentation purposes, it is _not_ used for maintaining paged data."
So my reading would suggest there is no way to multiple-layer-fragment
an SKB; the frags are page pointers and offsets, not entire sk_buff
structs in their own right.

-Ed
