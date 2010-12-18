From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netlink: fix gcc -Wconversion compilation warning
Date: Fri, 17 Dec 2010 22:58:01 -0800
Message-ID: <m1oc8jlg92.fsf@fess.ebiederm.org>
References: <1292259913-9911-1-git-send-email-kirill@shutemov.name>
	<m1sjy1uzj6.fsf@fess.ebiederm.org>
	<20101217.120234.59681524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kirill@shutemov.name, netdev@vger.kernel.org, pablo@netfilter.org,
	ldv@altlinux.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101217.120234.59681524.davem@davemloft.net> (David Miller's
	message of "Fri, 17 Dec 2010 12:02:34 -0800 (PST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 13 Dec 2010 13:35:25 -0800
>
>> "Kirill A. Shutsemov" <kirill@shutemov.name> writes:
>> 
>>> From: Dmitry V. Levin <ldv@altlinux.org>
>>>
>>> $ cat << EOF | gcc -Wconversion -xc -S -o/dev/null -
>>> unsigned f(void) {return NLMSG_HDRLEN;}
>>> EOF
>>> <stdin>: In function 'f':
>>> <stdin>:3:26: warning: negative integer implicitly converted to unsigned type
>>>
>> This doesn't look like a bad fix, but I believe things will fail if
>> we give NLMSG_ALIGN an unsigned long like size_t.  Say like sizeof.
>
> What are you talking about? That's exactly his test case,
> look at what NLMSG_HDRLEN is defined to, it's exactly the
> case you're worried "will fail", it passes sizeof() to
> NLMSG_ALIGN.
>
> I think I'll apply Kirill's original patch, it's good enough
> and simpler.

Probably.  The case I was worried about was masks that become
0xffffffxx on 64bit instead of 0xffffffffffffxx.  Especially
when mixing those with ints.

It is possible to get some really weird things.

Eric
