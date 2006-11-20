From: Joe Malicki <jmalicki@metacarta.com>
Subject: Re: [PATCH] AF_UNIX recv/shutdown race
Date: Mon, 20 Nov 2006 07:46:27 -0500
Message-ID: <4561A3A3.7020102@metacarta.com>
References: <20061120120517.GD1001@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from silene.metacarta.com ([65.77.47.18]:1492 "EHLO
	silene.metacarta.com") by vger.kernel.org with ESMTP
	id S965767AbWKTMq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 07:46:58 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061120120517.GD1001@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 20-11-2006 00:40, jmalicki@metacarta.com wrote:
> ...
> 
>>@@ -650,7 +651,7 @@ static int unix_autobind(struct socket *
>> 	struct unix_address * addr;
>> 	int err;
>>
>>-	mutex_lock(&u->readlock);
>>+	unix_state_rlock(sk);
> 
> 
> Here follows:
>         err = 0;
>         if (u->addr)
>                 goto out;
> 
>         err = -ENOMEM;
>         addr = kzalloc(sizeof(*addr) + sizeof(short) + 16, GFP_KERNEL);
>         if (!addr)
>                 goto out;
> 
> Are you sure you can use spin_lock here? 
> 
> Jarek P.

You're absolutely right, I was mistaken (was being too blind about
that).  I'm testing a new version now that's much more localized that
shouldn't have that problem.

Joe Malicki
