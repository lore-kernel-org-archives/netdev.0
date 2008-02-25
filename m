From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Nework Emulation with UML, bug 8895
Date: Sun, 24 Feb 2008 16:17:17 -0800
Message-ID: <20080224161717.ea1cad47.akpm@linux-foundation.org>
References: <47C019D2.4060308@club-internet.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@wide.ad.jp>
To: clowncoder <vincent-perrier@club-internet.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:43175 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752172AbYBYARa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 19:17:30 -0500
In-Reply-To: <47C019D2.4060308@club-internet.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Feb 2008 14:04:18 +0100 clowncoder <vincent-perrier@club-internet.fr> wrote:

> Hello,
> You can have a configured and running network inside a single linux machine,
> only one script command is enough. After the start of all the machine, a
> graphical representation of your topology helps your interactions with
> the network. This virtual network can be downloaded at http://clownix.net,
> I must warn you, it is a 350mega bz2 file-system that needs 4 giga on 
> the host.
> Very usefull for networking development in kernel as proved by bug 8895
> that has been found with the above tool:
> 
> The uncorrected bug 8895:
> 
> file:  /usr/src/linux-2.6.24.2/net/ipv6/ip6_fib.c  line  796:   
> "dst_free(&rt->u.dst);"
> 
> ------- /Comment From qmiao <mailto:qmiao@centecnetworks.com> 2007-08-29 
> 23:33:07 /---
> 
>         fib6_add
>                 ...
> 
>                 if (fn->leaf == NULL) {
>                         fn->leaf = rt;    <--**-- rt is assigned to fn->leaf
>                         atomic_inc(&rt->rt6i_ref);
>                 }
>                 ...
>                 err = fib6_add_rt2node(fn, rt, info); <-**- return -EEXIST
>                 ...
> (Here err was not null)
>                 ...
>                 if (err) {
>                         ...
>                         dst_free(&rt->u.dst); <--**-- Actually rt is still in
> tree (fn->leaf = rt /* see above */)
>                         ...
>                         }
> 

Please cc netdev on net-related bug reports.


