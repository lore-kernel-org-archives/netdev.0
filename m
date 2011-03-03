From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: inetpeer with create==0
Date: Thu, 3 Mar 2011 14:27:40 +0800
Message-ID: <AANLkTi=Ty+C3b9U+151dUMpgGiwG3AE4dMmc3djWmp6v@mail.gmail.com>
References: <20110302.204545.193730647.davem@davemloft.net>
 <AANLkTimwaUaC7Xu2djSNR9k98sYbSM0V88sCAc34R6Ac@mail.gmail.com> <20110302.213634.189680857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33652 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab1CCG2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 01:28:09 -0500
Received: by fxm17 with SMTP id 17so792170fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 22:28:07 -0800 (PST)
In-Reply-To: <20110302.213634.189680857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2011 at 1:36 PM, David Miller <davem@davemloft.net> wrote:
>
> Because trie eliminates all of the issues of having to size a hash
> table, dynamically resize it, etc.
>
> Trie gives well bounded performance dependent solely upon size of
> the table, rather than access patterns, distribution of keys, and
> how perfect hash function is.

Thanks for your explaination. Routing cache has all of these issues. :)

>
> We used to use a hash table for the page cache too, but now we use
> a trie structure there as well, and that uses full long word sized
> keys and the generic raidx-tree code.
>
> Using hash tables is really foolish for potentially large data sets.
>

However, I don't agree with you at every aspect.

Radix tree may cost lots of memory than a rbtree, avl tree or hash
table. Here is a case: turning to rbtree from radix tree.
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commit;h=8549164143a5431f9d9ea846acaa35a862410d9c

Since the keys of inetpeer rely on the access pattern, a attacker may
do a OOM DoS attack using sparse keys. We can't simply limit the
number of inetpeers to limit the memory cost of this subsystem. We
have to count the memory used for the inner branches of a radix tree.
Nevertheless, a attacker may also make this OS inefficiency by reduce
the max number of inetpeers.

Hash table + jhash have been proven a safe and efficient data
structure for large data sets(conntrack and ipvs), although the size
of the hash table may have to be adjusted by an administrator.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
