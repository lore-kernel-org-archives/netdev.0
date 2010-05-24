From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Fix error handling in do_setlink()
Date: Sun, 23 May 2010 23:12:20 -0700 (PDT)
Message-ID: <20100523.231220.155367105.davem@davemloft.net>
References: <20100521122527.20442.77793.stgit@warthog.procyon.org.uk>
	<20100522065212.GW8301@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51818
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753095Ab0EXGMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:12:10 -0400
In-Reply-To: <20100522065212.GW8301@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Wright <chrisw@sous-sol.org>
Date: Fri, 21 May 2010 23:52:12 -0700

> * David Howells (dhowells@redhat.com) wrote:
>> Commit c02db8c6290bb992442fec1407643c94cc414375:
>> 
>> 	Author:  Chris Wright <chrisw@sous-sol.org>
>> 	Date:    Sun May 16 01:05:45 2010 -0700
>> 	Subject: rtnetlink: make SR-IOV VF interface symmetric
>> 
>> adds broken error handling to do_setlink() in net/core/rtnetlink.c.  The
>> problem is the following chunk of code:
>> 
>> 	if (tb[IFLA_VFINFO_LIST]) {
>> 		struct nlattr *attr;
>> 		int rem;
>> 		nla_for_each_nested(attr, tb[IFLA_VFINFO_LIST], rem) {
>> 			if (nla_type(attr) != IFLA_VF_INFO)
>>   ---->				goto errout;
>> 			err = do_setvfinfo(dev, attr);
>> 			if (err < 0)
>> 				goto errout;
>> 			modified = 1;
>> 		}
>> 	}
>> 
>> which can get to errout without setting err, resulting in the following error:
>> 
>> net/core/rtnetlink.c: In function 'do_setlink':
>> net/core/rtnetlink.c:904: warning: 'err' may be used uninitialized in this function
>> 
>> Change the code to return -EINVAL in this case.  Note that this might not be
>> the appropriate error though.
>> 
>> Signed-off-by: David Howells <dhowells@redhat.com>
> 
> Acked-by: Chris Wright <chrisw@sous-sol.org>

Applied, thanks.
