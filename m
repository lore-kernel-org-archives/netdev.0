From: Jon Maloy <maloy@donjonn.com>
Subject: Re: [PATCH net-next 2/3] tipc: message reassembly using fragment
 chain
Date: Mon, 28 Oct 2013 06:24:09 -0400
Message-ID: <526E3B49.9030506@donjonn.com>
References: <1382812863-23571-1-git-send-email-jon.maloy@ericsson.com> <1382812863-23571-3-git-send-email-jon.maloy@ericsson.com> <20131028.010737.400887499395331496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm29-vm1.bullet.mail.bf1.yahoo.com ([98.139.213.144]:36639 "EHLO
	nm29-vm1.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754133Ab3J1KYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 06:24:13 -0400
In-Reply-To: <20131028.010737.400887499395331496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2013 01:07 AM, David Miller wrote:
> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Sat, 26 Oct 2013 14:41:02 -0400
>
>> +			int ret = tipc_link_recv_fragment(
>> +					&node->bclink.reasm_head,
>> +					&node->bclink.reasm_tail,
>> +					&buf);
> This is not the correct way to indent a function call that spans
> multiple lines.  In such a situation the arguments that appear
> on the second and subsequent lines must start at the first column
> after the openning parenthesis of the function call.
>
> Like this:
>
> 	func(a, b, c,
> 	     d, e, f);
>
> Please audit this in your entire set of patches and resubmit,
> thanks.

Doing as David says here means that some lines will be >80 chars.
This was the reason for the somewhat strange indentation.
I tried to rename the function to tipc_link_rcv_fragm(), but one
line was still too long. The problem we have goes deeper.

In Linus' coding style manual I read that the 80 char limit is a hard limit,
a limit we violate in several places. One offender is that we have too
many indentation levels, at least in tipc_recv_msg() and probably in
some other places. This is sensitive code, that I don't feel for touching
right now.  A more low hanging fruit is our local variable names:
names such as l_ptr, n_ptr, b_ptr is exactly what Linus characterizes
as "brain dead Hungarian style", and I never liked that naming anyway.
For me l, n, and b is good enough as long as the context is clear.

But, doing so, at least in tipc_recv_msg(), would require another, separate,
patch, and it would lead to style inconsistency.

In brief, I am at loss about to proceed here, and I am not going to submit
this patch again until I have some feedback from somebody who can tell me
what is the right thing to do. Maybe > 80 chars is fine for now?

///jon
