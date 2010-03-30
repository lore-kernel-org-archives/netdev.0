From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] a 'ip rule ...' bug?
Date: Mon, 29 Mar 2010 19:42:14 -0700
Message-ID: <20100329194214.3ea61b67@s6510>
References: <f4f837ab1003260515y54f0db76vc19c966f39e1d3a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53163 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754882Ab0C3CmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 22:42:17 -0400
In-Reply-To: <f4f837ab1003260515y54f0db76vc19c966f39e1d3a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Mar 2010 20:15:30 +0800
thomas yang <lampsu@gmail.com> wrote:

> in  /etc/iproute2/rt_dsfield
> ...
> # Newer RFC2597 values
> 0x28	AF11
> 0x30	AF12
> 0x38	AF13
> ...


> ---in   ip  man page ---
> ip rule add - insert a new rule
> 
> tos TOS
> dsfield TOS
>     select the TOS value to match.
> ---

Read the syntax on the man page:
       ip rule  [ list | add | del | flush ] SELECTOR ACTION

       SELECTOR := [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark
               FWMARK[/MASK] ] [ dev STRING ] [ pref NUMBER ]


There is no mention of dsfield argument.

> 
> [root@localhost ~]# ip rule add dsfield 0x28 table 200
> Error: argument "dsfield" is wrong: Failed to parse rule type
> 
> why???
> how to match 'dsfield' ?
> 
> [root@localhost ~]# ip rule add tos 0x28 table 200
> RTNETLINK answers: Invalid argument
> 
> (My OS is Fedora 11 :  kernel-2.6.30.10-105.2.23.fc11.i586 ,
> iproute-2.6.29-2.fc11.i586 ;
> on my another linux box ( Fedora 7)   'ip rule'  also has the same
> problem  to match  tos and dsfield. )

TOS field is masked by down to only 2 bits. 
See include/net/route.h in kernel source.
I think the reason was that with original TOS (pre dsfield) route design,
the implementors wanted to save space.

