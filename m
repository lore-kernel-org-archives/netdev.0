From: Alexei Starovoitov <ast@fb.com>
Subject: Re: bpf pointer alignment validation
Date: Wed, 10 May 2017 09:15:02 -0700
Message-ID: <5fe8754f-9c55-a99e-73ef-9a0f254366d9@fb.com>
References: <20170510055735.hfkoh4w3xaka5yl5@ast-mbp>
 <20170510.113357.362211347006868605.davem@davemloft.net>
 <59133716.7060800@iogearbox.net>
 <20170510.115720.1396306489898364855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60152 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752894AbdEJQPq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 12:15:46 -0400
In-Reply-To: <20170510.115720.1396306489898364855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/17 8:57 AM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Wed, 10 May 2017 17:51:50 +0200
>
>> Would probably be good nevertheless to have this as a flag for
>> program loads, which gets then passed through to the verifier to
>> explicitly enable strict alignment checks.
>>
>> Might certainly aide developing & testing programs on archs with
>> efficient unaligned access and later actually running them on archs
>> that don't have it. (And at minimum, it also helps for checking
>> the test suite against the verifier.)
>
> Ok, I can implement this flag.
>
> The only question is where to put it?  An unused bit in the program
> type? :-)

just add '__u32 prog_flags' to bpf_attr PROG_LOAD anon union.
There was no need for such flags in the past, hence no flags field
existed. Now it's time.
