From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 14/14] replace __inline__ by inline in include/linux (net
 related)
Date: Wed, 06 Feb 2008 13:13:55 +0100
Message-ID: <47A9A483.6060709@fr.ibm.com>
References: <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com> <20080206.213100.60768610.yoshfuji@linux-ipv6.org> <47A98E5F.7010207@fr.ibm.com> <20080206.032709.166069933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:32736 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761592AbYBFMTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 07:19:30 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m16CJTT8459536
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 12:19:29 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16CJTfE3907830
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 12:19:29 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16CJPQZ017140
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 12:19:26 GMT
In-Reply-To: <20080206.032709.166069933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> Date: Wed, 06 Feb 2008 11:39:27 +0100
> 
>> YOSHIFUJI Hideaki / 吉藤英明 wrote:
>>> In article <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com> (at Wed, 06 Feb 2008 10:14:19 +0100), Daniel Lezcano <dlezcano@fr.ibm.com> says:
>>>
>>>> replace __inline__ by inline in include/linux (net related)
>>>>
>>>> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
>>>> ---
>>>>  include/linux/atm.h        |    4 ++--
>>>>  include/linux/atmsap.h     |    2 +-
>>>>  include/linux/hdlc.h       |   13 +++++++------
>>>>  include/linux/inetdevice.h |   14 ++++++--------
>>>>  include/linux/netlink.h    |    5 +++--
>>>>  include/linux/rtnetlink.h  |    2 +-
>>>>  6 files changed, 20 insertions(+), 20 deletions(-)
>>> Please do this change within the #ifdef __KERNEL__ .. #endif only.
>> Oups ! I didn't thought about userspace program when modifying these 
>> headers. Thanks for catching this.
>>
>> Hopefully, the patches can be applied separately. Is it possible to 
>> discard this one ?
> 
> What is the real problem though?
> 
> Oh, c89 style C compilation will break with plain "inline"?

If a userspace program include one of these headers and compile with the
-ansi option, the keyword "inline" will be disabled and the compilation
will fail. For this reason when a header is exported, the __inline__
keyword should be used instead of "inline" to avoid such problem.
