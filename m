From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: TIPC security issues
Date: Fri, 22 Oct 2010 09:49:21 -0400
Message-ID: <0434463FDA60A94FA978ACA44617682DEE846B4D37@EUSAACMS0702.eamcs.ericsson.se>
References: <1287704752.11051.79.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "security@kernel.org" <security@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>,
	"allan.stephens@windriver.com" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.8]:45574 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755283Ab0JVNvN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 09:51:13 -0400
In-Reply-To: <1287704752.11051.79.camel@Dan>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked. We clearly have a couple of things to fix here.
We'll try to get it done asap.

///jon



> -----Original Message-----
> From: Dan Rosenberg [mailto:drosenberg@vsecurity.com] 
> Sent: October-21-10 19:46
> To: Jon Maloy; allan.stephens@windriver.com
> Cc: security@kernel.org; netdev@vger.kernel.org
> Subject: TIPC security issues
> 
> The tipc_msg_build() function in net/tipc/msg.c is written in 
> such a way as to create a highly exploitable kernel heap 
> overflow that would allow a local user to escalate privileges 
> to root by issuing maliciously crafted sendmsg() calls.  At a 
> minimum, the following issues should be
> fixed:
> 
> 1. The tipc_msg_calc_data_size() function is almost totally 
> broken.  It sums together size_t values (iov_lens), but 
> returns an integer.  Two things can go wrong - the total 
> value can wrap around, or on 64-bit platforms, iov_len values 
> greater than UINT_MAX will be truncated.
> 
> 2. The comparison of dsz to TIPC_MAX_USER_MSG_SIZE is signed, 
> so negative (large unsigned) values will pass this check.
> 
> 3. The comparison of sz to max_size is also signed.
> 
> As a result of these issues, it's possible to cause the 
> allocation of a small heap buffer and the subsequent copying 
> of a carefully controlled larger amount of data into that buffer.
> 
> I haven't found a Linux distribution that defines a module 
> alias for TIPC (even though most compile it as a module), so 
> an administrator will have had to explicitly load the TIPC 
> module for a system to be vulnerable.
> 
> -Dan
> 
> 