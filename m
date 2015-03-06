From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: drop (int) cast on length arg in NLMSG_OK
Date: Thu, 05 Mar 2015 21:43:28 -0500 (EST)
Message-ID: <20150305.214328.1364725716743583555.davem@davemloft.net>
References: <1425534428-24182-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vapier@gentoo.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425534428-24182-1-git-send-email-vapier@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier@gentoo.org>
Date: Thu,  5 Mar 2015 00:47:08 -0500

> The NLMSG_OK macro compares three things:
>  - the len arg from the user
>  - a size_t: sizeof(struct nlmsghdr)
>  - an int: sizeof(struct nlmsghdr) casted
>  - an u32: the nlmsghdr->nlmsg_len member
> 
> When building with -Wsign-compare, this macro triggers a signed compare
> warning.  This is because it compares len to an int, and then compares
> it to a u32.  If len is signed, we get a warning due to the last test.
> If len is unsigned, we get a warning due to the first test.  Like in
> strace:
> socketutils.c:145:8: warning: comparison between signed and unsigned
>                               integer expressions [-Wsign-compare]
> 
> Lets drop the int cast on the first sizeof.  This way, once the user
> casts len to an unsigned value, everything shakes out correctly.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

I don't think we can change this.  If you get rid of the 'int' cast
then code is going to end up with a signed comparison for the first
test even if 'len' is signed, and that's a potential security issue.
