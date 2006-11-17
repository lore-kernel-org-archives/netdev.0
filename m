From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] IPv6: Fix NULL dereference in ipv6_del_addr()
Date: Fri, 17 Nov 2006 21:27:21 +0200
Message-ID: <455E0D19.1060405@tcs.hut.fi>
References: <455DB884.3050203@tcs.hut.fi> <20061117.232623.61341274.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:60820 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1755826AbWKQT1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 14:27:23 -0500
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
In-Reply-To: <20061117.232623.61341274.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki wrote:
> In article <455DB884.3050203@tcs.hut.fi> (at Fri, 17 Nov 2006 15:26:28 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
> 
> 
>> -		dst_release(&rt->u.dst);
>> +		if (rt)
>> +			dst_release(&rt->u.dst);
>>  	}
> 
> I disagree.  This does NOT fix any bugs.
> 
> (void *)&rt->u.dst is ever equal to (void*)rt, and
> dst_release() checks if the argument is NULL.

As the check is unnecessary you probably want to clean up the other 
places where rt is checked before &rt->u.dst is passed, as well ;-)
This is done at least in addrconf.c, ndisc.c and route.c...

Seriously though, you are probably right about the pointer being equal 
to NULL in this case,  but does the C language actually guarantee that 
the pointer to the structure and its first element are equal, or is it 
implementation dependent? I don't have my K&R here, so I can't check.

Regards,
Ville


