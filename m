From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/7] Deconstruct struct fib_result
Date: Fri, 27 Jul 2012 23:41:50 -0700
Message-ID: <CAKgT0UcuvFGJTCxMwVa+rEnQHaNg0V6EH4XpO29fXuFADSBpAQ@mail.gmail.com>
References: <20120727.211814.1628871775065221675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:65223 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785Ab2G1Glv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 02:41:51 -0400
Received: by vcbfk26 with SMTP id fk26so3393231vcb.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 23:41:51 -0700 (PDT)
In-Reply-To: <20120727.211814.1628871775065221675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 27, 2012 at 9:18 PM, David Miller <davem@davemloft.net> wrote:
>
> This patch set tries to move towards reducing struct fib_result down
> to it's absolute minimum.
>
> The eventual idea is to make it so that fib_lookup() simply
> returns a "struct fib_nh *" and pointer encoded errnos, instead
> of writing into a complicated structure as the return value on
> the stack as is done now.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

I was wondering why you couldn't wrap the tclassid value in result
with an #ifdef CONFIG_IP_ROUTE_CLASSID so that it is stripped if you
don't have that defined?  I did a quick grep through the kernel and it
seems like there are only a few spots that are accessing it without
the define being checked and most of those are just setting it to 0.

Also is there any specific reason to be passing the trie pointer to
check_leaf?  From what I can tell it looks like that it is just used
for updating the trie stats that are stripped if we want performance,
and the trie pointer should be retrievable via the fib table pointer
if we really wanted it anyway.

Thanks,

Alex
