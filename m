From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x641/0xd30()
Date: Fri, 10 Aug 2012 22:40:18 +0200
Message-ID: <1344631218.31104.2745.camel@edumazet-glaptop>
References: <20120806154616.GB2187@redhat.com>
	 <20120810202910.GA19359@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:64397 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab2HJUkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 16:40:23 -0400
Received: by wicr5 with SMTP id r5so789161wic.1
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 13:40:21 -0700 (PDT)
In-Reply-To: <20120810202910.GA19359@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 16:29 -0400, Dave Jones wrote:
> On Mon, Aug 06, 2012 at 11:46:16AM -0400, Dave Jones wrote:
>  > We just got an automated report of this WARN being hit in 3.5
>  > 
>  >  > backtrace:
>  >  > :WARNING: at net/ipv4/tcp.c:1598 tcp_recvmsg+0x641/0xd30()
>  >  > :Hardware name: P5Q DELUXE
>  >  > :recvmsg bug: copied 99F66400 seq 99F6A4A8 rcvnxt 99F6CDAD fl 0
>  >  > : [<ffffffff811848e6>] do_sync_read+0xe6/0x120
>  >  > : [<ffffffff81275eea>] ? inode_has_perm.isra.31.constprop.61+0x2a/0x30
>  >  > : [<ffffffff81272f32>] ? security_file_permission+0x92/0xb0
>  >  > : [<ffffffff81184d81>] ? rw_verify_area+0x61/0xf0
>  >  > : [<ffffffff811852cd>] vfs_read+0x15d/0x180
>  >  > : [<ffffffff8118533a>] sys_read+0x4a/0x90
>  >  > : [<ffffffff8160fc29>] system_call_fastpath+0x16/0x1b
>  > 
>  > 1594                         /* Now that we have two receive queues this
>  > 1595                          * shouldn't happen.
>  > 1596                          */
>  > 1597                         if (WARN(before(*seq, TCP_SKB_CB(skb)->seq),
>  > 1598                                  "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
>  > 1599                                  *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
>  > 1600                                  flags))
>  > 1601                                 break;
>  > 
>  > 
>  > Hopefully this means more to you guys than it does to me.
> 
> We're getting more reports of this happening too.
> 
> This guy managed to hit both of the recvmsg BUG's.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=846996
> https://bugzilla.redhat.com/show_bug.cgi?id=846991
> 
> The first reporter claimed to be doing nothing special, just browsing with google chrome.
> 
> Anyone ?

Might be a driver issue with LRO / GRO/ TCP coalescing

So we need a _lot_ of details.
