From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: no IPv6 Routers present
Date: Fri, 13 Mar 2009 11:43:31 -0400
Message-ID: <49BA7F23.9040204@hp.com>
References: <gpbtfk$s5h$1@ger.gmane.org> <49B99811.6050304@hp.com> <loom.20090313T082825-818@post.gmane.org> <49BA49C6.2020007@hp.com> <loom.20090313T131931-421@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: feldmaus <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:9915 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbZCMPne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 11:43:34 -0400
In-Reply-To: <loom.20090313T131931-421@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

feldmaus wrote:
> Vlad Yasevich <vladislav.yasevich <at> hp.com> writes:
> 
>> Get rid of NOARP in you eth0 case, and it should work.
>>
> It seems to better, but i do not know how the <NOARP> comes from ?
> 
> I changed my </etc/network/interfaces> from:
> iface dsl-provider inet ppp
>     pre-up /sbin/ifconfig eth0 up -arp 0# line maintained by pppoeconf
>     provider dsl-provider
> 
> to this one:
> iface dsl-provider inet ppp
>     pre-up /sbin/ifconfig eth0 up # line maintained by pppoeconf
>     provider dsl-provider
> 
> Should this the key ?
> 

Aha...  you probably want to add a

	post-down /sbin/ifconfig eth0 arp

So that the next time you configure eth0, it will be able to
arps again.

-vlad

> Regards Markus
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

