From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] seccomp: fix populating a0-a5 syscall args in 32-bit
 x86 BPF
Date: Mon, 14 Apr 2014 16:24:52 -0400 (EDT)
Message-ID: <20140414.162452.1169041476405438694.davem@davemloft.net>
References: <1397502179-15029-1-git-send-email-dborkman@redhat.com>
	<534C4179.7070704@amacapital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	ast@plumgrid.com, eparis@redhat.com, james.l.morris@oracle.com,
	keescook@chromium.org
To: luto@amacapital.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <534C4179.7070704@amacapital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 14 Apr 2014 13:13:45 -0700

> I think this description is wrong.  (unsigned long *) &sd->args[1] is
> the right location, at least on 32-bit little-endian architectures.

It absolutely is not.

The thing is a u64, and we must respect that type in a completely
portable way.

Daniel's change is %100 correct, portable, and doesn't have any
ugly ifdef crap.

If you want to optimize this, and potentially break it again, do
it in the next merge window not now.

I'm going to apply Daniel's patch.
