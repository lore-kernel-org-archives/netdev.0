From: Steve Rago <sar@nec-labs.com>
Subject: Re: bug in passing file descriptors
Date: Mon, 7 Oct 2013 15:17:24 -0400
Message-ID: <525308C4.1030007@nec-labs.com>
References: <5252FD2B.5040800@nec-labs.com> <CALCETrXmmW-nRTr4-yWJnNr2GWW37KW-7B1m=kSRnmYjhMTajA@mail.gmail.com> <5253061A.7060701@nec-labs.com> <20131007.151233.2237348893254566536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <luto@amacapital.net>, <netdev@vger.kernel.org>,
	<mtk.manpages@gmail.com>, <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nec-labs.com ([138.15.200.209]:52272 "EHLO
	mail.nec-labs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659Ab3JGTR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:17:28 -0400
In-Reply-To: <20131007.151233.2237348893254566536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2013 03:12 PM, David Miller wrote:
> From: Steve Rago <sar@nec-labs.com>
> Date: Mon, 7 Oct 2013 15:06:02 -0400
>
>> Maybe.  So a client expecting to receive x bytes of control
>> information should make sure their buffer is at least CMSG_SPACE(x)
>> bytes long instead of CMSG_LEN(x) bytes long, because you feel
>> compelled to copy the final padding from kernel space to user space?
>> Seems wrong to me.  IMHO, the final padding should only come into play
>> when calculating where the next header should begin.
>
> Yes, all control messages must be aligned to, and be of a length of a
> multiple of, "sizeof(long)".
>
> This is the only correct way to program control messages.
>

Except when sizeof(long) can change and you need to maintain binary compatibility with older applications.  x86 comes to 
mind as a relevant example: used to be 32 bits, but is 64 now.

Steve
