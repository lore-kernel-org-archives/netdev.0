From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] garp: fix a NULL pointer dereference bug
Date: Mon, 04 Mar 2013 06:56:15 -0800
Message-ID: <1362408975.15793.92.camel@edumazet-glaptop>
References: <1362368217-30984-1-git-send-email-amwang@redhat.com>
	 <1362374790.15793.87.camel@edumazet-glaptop> <1362390955.2383.2.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugs@syam.in,
	David Ward <david.ward@ll.mit.edu>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:46051 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641Ab3CDO4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 09:56:18 -0500
Received: by mail-pa0-f52.google.com with SMTP id fb1so3206692pad.25
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 06:56:17 -0800 (PST)
In-Reply-To: <1362390955.2383.2.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-04 at 17:55 +0800, Cong Wang wrote:
> On Sun, 2013-03-03 at 21:26 -0800, Eric Dumazet wrote:
> > 
> > Nope this patch doesnt solve the problem
> > 
> > Crash is in :
> > 
> > 49 8b 1c c6             mov    (%r14,%rax,8),%rbx 
> > 
> > Thats because r14 (port) is NULL
> > 
> > 
> > 
> 
> Hmm, but I can't see how it can be NULL, the only place of NULL'ing it
> is inside garp_release_port(), right after the piece of code that I
> patched.
> 
> Thanks!
> 

Maybe port is NULL from the beginning.

Try to inject memory allocations error in garp_init_port()
