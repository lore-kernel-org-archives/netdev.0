From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [PATCH] Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 23 Jan 2007 12:52:06 +0100
Message-ID: <7d01f9f00701230352r6e951b08wea2255ce0baeb40d@mail.gmail.com>
References: <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
	 <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com>
	 <20070109200541.GA27089@xyzzy.farnsworth.org>
	 <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com>
	 <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com>
	 <20070111104220.GA3171@ff.dom.local>
	 <7d01f9f00701210418q6f506d20tdc9ce10b501370d7@mail.gmail.com>
	 <7d01f9f00701210502m2bb96bd8i5071a76b6a8c3ea0@mail.gmail.com>
	 <20070122100236.GC2079@ff.dom.local>
	 <20070122170615.GA15293@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:60525 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932975AbXAWLwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 06:52:08 -0500
Received: by wr-out-0506.google.com with SMTP id i22so942403wra
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 03:52:08 -0800 (PST)
To: "Dale Farnsworth" <dale@farnsworth.org>
In-Reply-To: <20070122170615.GA15293@xyzzy.farnsworth.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/22/07, Dale Farnsworth <dale@farnsworth.org> wrote:
> Jarek and Thibaut,
>
> Thank you both very much for your work finding and fixing this bug.
> Jarek, can you verify that the following patch fixes the problem you
> were seeing?
>
> -Dale

Hi Dale,

The patch seems to work fine. Just thinking out loud (as I really
don't know this part of the kernel), here are a few remarks:

- As Jarek pointed out, you're checking twice the value of
mp->tx_desc_count, which means dereferencing a pointer and accessing
memory twice. I don't know how perf-critical this bit of code is, but
I wonder which of keeping the lock for a long time or doing what you
is better (I'm being anal and you probably know that better than me :)

- Also, lines 344-349, in the test condition, cmd_sts (an indirection
to mp content) is accessed (dunno if it's ok to do that outside of the
lock), and on line 346, mp->stats.tx.errors is incremented outside of
the spinlock protection. But then, I don't know what that lock is
meant to protect, just pointing this out :)

Thanks for your help, I hope the fix will go upstream asap :)

And about being the author of the patch, since I'm not, I don't really mind 8)

HTH

T-Bone

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
