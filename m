From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Shrink struct dst_entry a bit
Date: Tue, 13 Mar 2007 15:44:57 +0100
Message-ID: <200703131544.57757.dada1@cosmosbay.com>
References: <200703131448.15193.ak@suse.de> <200703131510.41651.dada1@cosmosbay.com> <200703131531.14548.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:43114 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030429AbXCMOou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 10:44:50 -0400
In-Reply-To: <200703131531.14548.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 March 2007 15:31, Andi Kleen wrote:

> Ok.  When you do such changes you should always add a comment, otherwise
> it will be always destroyed with the next change.
>
> But it seems highly fragile to me anyways because it depends on the exact
> value of RTAX_MAX which tends to change regularly when someone invents
> a new attribute. You should probably have moved next out of the dst entry.

Not an option, unfortunately. But yes, a comment is needed.
(Before my february patches, the 'next' pointer was forced to be the first 
field of dst).

>
> Anyways here's a new patch with next still at the end and a comment.
>

Andi, did you actually test your patch ?

Unless I really miss something obvious, rate_last is supposed to store 
jiffies.

net/ipv4/route.c:1313:  if (time_after(jiffies, rt->u.dst.rate_last + 
ip_rt_redirect_silence))

So you *cannot* convert it to 'unsigned short'. Really.


However, you could convert it to a u32, and use a helper function :

static inline u32 get_jiffies_32()
{
return (u32)jiffies;
}

and change appropriate code using rate_last

Also, 'lastuse' could use a u32 too, I even had a patch for this one...

