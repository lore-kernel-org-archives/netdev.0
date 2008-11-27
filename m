From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 5/6] fs: Introduce special inodes
Date: Thu, 27 Nov 2008 00:20:46 -0800 (PST)
Message-ID: <20081127.002046.25550570.davem@davemloft.net>
References: <4926D39D.9050603@cosmosbay.com>
	<20081121153453.GA23713@elte.hu>
	<492DDC99.5060106@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-X9Un+BFzKDI@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, efault-Mmb7MZpHnFY@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <492DDC99.5060106-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Date: Thu, 27 Nov 2008 00:32:41 +0100

> Goal of this patch is to not touch inode_lock for socket/pipes/anonfd
>  inodes allocation/freeing.
> 
>  In new_inode(), we test if super block has MS_SPECIAL flag set.
>  If yes, we dont put inode in "inode_in_use" list nor "sb->s_inodes" list
>  As inode_lock was taken only to protect these lists, we avoid it as well
> 
>  Using iput_special() from dput_special() avoids taking inode_lock
>  at freeing time.
> 
>  This patch has a very noticeable effect, because we avoid dirtying of three contended cache lines in new_inode(), and five cache lines
>  in iput()
> 
> Note: Not sure if we can use MS_SPECIAL=MS_NOUSER, or if we
> really need a different flag.
> 
> (socket8 bench result : from 20.5s to 2.94s) 
> 
> Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>

No problem with networking part:

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
