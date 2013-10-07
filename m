From: Andi Kleen <andi@firstfloor.org>
Subject: Re: bug in passing file descriptors
Date: Mon, 07 Oct 2013 15:55:02 -0700
Message-ID: <87li24zo6x.fsf@tassilo.jf.intel.com>
References: <525308C4.1030007@nec-labs.com>
	<20131007.154226.533738557474978526.davem@davemloft.net>
	<5253199B.3000109@nec-labs.com>
	<20131007.173237.1669132001431607341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: sar@nec-labs.com, luto@amacapital.net, netdev@vger.kernel.org,
	mtk.manpages@gmail.com, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43326 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484Ab3JGWzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 18:55:15 -0400
In-Reply-To: <20131007.173237.1669132001431607341.davem@davemloft.net> (David
	Miller's message of "Mon, 07 Oct 2013 17:32:37 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Steve Rago <sar@nec-labs.com>
> Date: Mon, 7 Oct 2013 16:29:15 -0400
>
>> On 10/07/2013 03:42 PM, David Miller wrote:
>>> There is no compatability issue.
>>>
>>> 32-bit tasks will always see the 4-byte align/length.
>>> 64-bit tasks will always see the 8-byte align/length.
>>>
>> 
>> Really?  So when I compile my application on a 32-bit Linux box and
>> then try to run it on a 64-bit Linux box, you're not going to overrun
>> my buffer when CMSG_SPACE led me to allocate an insufficient amount of
>> memory needed to account for padding on the 64-bit platform?
>
> We have a compatability layer that gives 32-bit applications the
> same behavior as if they had run on a 32-bit machine.
>
> Search around for the MSG_MSG_COMPAT flag and how that is used in
> net/socket.c

But it seems the compat layer doesn't handle this correctly,
otherwise Steve's original test case would work.

Must be a bug somewhere in the compat layer.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
