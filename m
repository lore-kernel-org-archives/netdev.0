From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 07/12] xfrm: Move child route linkage into xfrm_dst.
Date: Thu, 26 Oct 2017 16:44:50 +0900 (KST)
Message-ID: <20171026.164450.1372666046811272701.davem@davemloft.net>
References: <20171025.230359.995821396512483745.davem@davemloft.net>
        <20171026070311.GS3323@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58824 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdJZHoz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 03:44:55 -0400
In-Reply-To: <20171026070311.GS3323@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 26 Oct 2017 09:03:11 +0200

> On Wed, Oct 25, 2017 at 11:03:59PM +0900, David Miller wrote:
>> 
>> XFRM bundle child chains look like this:
>> 
>> 	xdst1 --> xdst2 --> xdst3 --> path_dst
>> 
>> All of xdstN are xfrm_dst objects and xdst->u.dst.xfrm is non-NULL.
>> The final child pointer in the chain, here called 'path_dst', is some
>> other kind of route such as an ipv4 or ipv6 one.
>> 
>> The xfrm output path pops routes, one at a time, via the child
>> pointer, until we hit one which has a dst->xfrm pointer which
>> is NULL.
>> 
>> We can easily preserve the above mechanisms with child sitting
>> only in the xfrm_dst structure.  All children in the chain
>> before we break out of the xfrm_output() loop have dst->xfrm
>> non-NULL and are therefore xfrm_dst objects.
>> 
>> Since we break out of the loop when we find dst->xfrm NULL, we
>> will not try to dereference 'dst' as if it were an xfrm_dst.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> This one seems to be somewhat screwed up, it does not apply.
> Looks like your mail contains two patches, both have some overlap.

Weird, it's exactly like that in the *.patch file I generated
too.

I just tried to regenerate it using:

	git format-patch master..dst-shrink

'dst-shrink' is the branch where I work on this stuff.  And I
get the same exact result.

Weird.

Can't say that I've ever seen anything like this before :-)
