From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 4/4 (resent) net-2.6.25][UNIX] Make the unix sysctl tables
 per-namespace
Date: Sat, 01 Dec 2007 16:19:43 +0300
Message-ID: <47515F6F.1090805@openvz.org>
References: <47503919.8060103@openvz.org> <47503C48.8020001@openvz.org> <20071201125726.GC15910@gondor.apana.org.au> <47515C79.9060903@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Denis V. Lunev" <den@openvz.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35090 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345AbXLANUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 08:20:38 -0500
In-Reply-To: <47515C79.9060903@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> Herbert Xu wrote:
>> On Fri, Nov 30, 2007 at 07:37:28PM +0300, Pavel Emelyanov wrote:
>>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> All applied to net-2.6.25.
>>
>>> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
>>> index b0cf075..f97b2a4 100644
>>> --- a/include/net/net_namespace.h
>>> +++ b/include/net/net_namespace.h
>>> @@ -41,6 +43,7 @@ struct net {
>>>  
>>>  	/* unix sockets */
>>>  	int			sysctl_unix_max_dgram_qlen;
>>> +	struct ctl_table_header	*unix_ctl;
>>>  };
>> But I gotta say this struct/file is going to be enormous.  It's also
>> one of those files that causes everything to get recompiled.  Maybe
>> we ought to make a rule that each subsystem only gets to have at most
>> one entry in it :)
>>
>> Thanks,
> 
> Good point, thanks. We'll start thinking in that direction. Right now it
> is not finally cursed with all staff around.

Agree, the point is good :) but it has one pitfall :(

Look, now we make _one_ dereference to get any net->xxx variable 
(sysctl, list head, lock, etc). When we force each subsystem 
has it's "private" pointer on this, we'll make them take _two_ 
dereferences. Before the whole net namespace stuff started we
made _zero_ dereferences :) This may tell upon the performance.

I'm not claiming that this is the major case against this idea,
but when developing this idea, I think we should keep that fact
in ming and pay good attention to performance regressions.

> Regards,
> 	Den

Thanks,
Pavel

