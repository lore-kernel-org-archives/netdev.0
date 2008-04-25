From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Thu, 24 Apr 2008 23:31:59 -0700 (PDT)
Message-ID: <20080424.233159.06679047.davem@davemloft.net>
References: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
	<OF3A37018B.9EFE360C-ON88257435.00614684-88257435.00622448@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756804AbYDYGcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:32:00 -0400
In-Reply-To: <OF3A37018B.9EFE360C-ON88257435.00614684-88257435.00622448@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Thu, 24 Apr 2008 11:52:01 -0600

> I was looking at this problem too, and below is what I have at the
> moment. I've only tested the group_req portion, and I was looking
> at putting this in net/compat.c with hooks back, since the code is
> literally identical for IPv4 except the sockopt function you call at
> the end, but I've moved it to ipv6_sockglue.c for this patch.
> 
> This touches a lot less code and I think comes out a lot smaller.
> 
> Method is to translate to padded version on the user stack, make
> the call, and translate back (in the MSFILTER case) on return, as
> is done for some other compat functions.

I've looked at both approaches.

David's might be the better way to do this, as an initial
approximation.

I think we can combine ideas from both implementations, so why don't
we do the following:

1) Use copy_in_user() as that's the proper interaface to copy within
   userspace in COMPAT code.

2) Use aligned(4) attribute instead of packed, this will help RISC
   compat systems a lot

If you make these changes and do some testing, I think this is the
patch I will apply.

Thanks.
