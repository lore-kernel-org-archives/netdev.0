From: Andrew Morton <akpm@osdl.org>
Subject: Re: nfsd oops with 2.6.5-rc2-mm4
Date: Sat, 27 Mar 2004 18:48:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327184840.20d9e282.akpm@osdl.org>
References: <20040327130757.GA6760@c9x.org>
	<Pine.LNX.4.58.0403271816450.20100@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, trond.myklebust@fys.uio.no, neilb@cse.unsw.edu.au,
        netdev@oss.sgi.com, fdenis@skyrock.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0403271816450.20100@ppc970.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@osdl.org> wrote:
>
> 
> This oops is on a 
> 
> 	lock incl 0x4(%edx)
> 
> and as far as I can tell, it's from do_tcp_sendpages():
> 
> 		....
> 
>                 i = skb_shinfo(skb)->nr_frags;
>                 if (can_coalesce(skb, i, page, offset)) {
>                         skb_shinfo(skb)->frags[i - 1].size += copy;
>                 } else if (i < MAX_SKB_FRAGS) {
> *********		get_page(page);			***************
>                         fill_page_desc(skb, i, page, offset, copy);
>                 } else {
>                         tcp_mark_push(tp, skb);
>                         goto new_segment;
>                 }
> 		...
> 
> where "page" is NULL.
> 
> The caller seems to be svc_sendto()->tcp_sendpage()->do_tcp_sendpages()  
> (the other addresses seem to be stale crud on the stack), which doesn't
> look like it has changed lately. Unless there are changes in this area in
> -mm..

There are some knfsd patches in -mm.

This one might be the cuplrit:

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.5-rc2/2.6.5-rc2-mm4/broken-out/knfsd-03-auth_error-formatting-fix.patch

Frank, if you have time it would be interesting to try reverting that (and
the other knfsd-* patches), see if the crash goes away.
