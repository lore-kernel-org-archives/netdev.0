From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor	implementation
 & Netlink protocol
Date: Thu, 02 Apr 2009 16:42:18 +0200
Message-ID: <49D4CECA.3010703@trash.net>
References: <20090304.030044.163418715.davem@davemloft.net> <20090402093952.GA30553@gondor.apana.org.au> <20090402.025223.242893473.davem@davemloft.net> <20090402095957.GA30799@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46895 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759969AbZDBOmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 10:42:31 -0400
In-Reply-To: <20090402095957.GA30799@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Apr 02, 2009 at 02:52:23AM -0700, David Miller wrote:
>> It has to do with how the netlink attributes get packed together
>> into the messages.  It's this crap:
>>
>> #define NLMSG_ALIGNTO	4
>> #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
>>  ...
>> #define NLMSG_NEXT(nlh,len)	 ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
>> 				  (struct nlmsghdr*)(((char*)(nlh)) + NLMSG_ALIGN((nlh)->nlmsg_len)))
>>
>> Thus, nothing in an nlmsg can ever be more than 4 byte aligned.
>> And this is hard coded into the protocol.
> 
> Ah yes, this is the killer.
> 
> I suppose we can modify in-kernel helpers like nla_parse to deal
> with that by copying if it's unaligned.  Though we'll have to
> figure out how to free the memory.

Actually we should be fine since the current netlink helpers only do
bytewise copying anyways. And I think we've pretty much gotten rid of
all the raw attribute accesses.
