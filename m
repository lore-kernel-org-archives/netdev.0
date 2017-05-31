From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 6/9] bpf: fix stack_depth usage by test_bpf.ko
Date: Wed, 31 May 2017 11:39:37 -0700
Message-ID: <73af1b50-38b0-b7f3-5c74-e425d47209b6@fb.com>
References: <20170530203135.3642768-1-ast@fb.com>
 <20170530203135.3642768-7-ast@fb.com>
 <20170531.141502.1137764740674039078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38070 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751053AbdEaSkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:40:06 -0400
In-Reply-To: <20170531.141502.1137764740674039078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/17 11:15 AM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Tue, 30 May 2017 13:31:32 -0700
>
>> test_bpf.ko doesn't call verifier before selecting interpreter or JITing,
>> hence the tests need to manually specify the amount of stack they consume.
>>
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> I do not like this and the previous patch, it seems so error prone.

in what sense 'error prone' ?
we cannot call verifier from test_bpf.ko, since the test are written
in raw (post-verifier) format and not uapi format.
If we decide to rewrite them most of the large tests will not pass
due to hitting verifier limits.
test_bpf is a unit test to test JITs. It shouldn't test verifier
or other bpf components. It's a job of test_verifier, test_maps
and other tests.
Hence the only way is to manually set stack_depth here.
