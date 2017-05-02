From: Alexei Starovoitov <ast@fb.com>
Subject: Re: bpf_test_finish()
Date: Mon, 1 May 2017 21:46:07 -0700
Message-ID: <a7f18cfe-049c-d580-8c15-5d09b6860c48@fb.com>
References: <20170501.235610.564976046138352257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60945 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751068AbdEBEq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 00:46:28 -0400
In-Reply-To: <20170501.235610.564976046138352257.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/17 8:56 PM, David Miller wrote:
>
> It dereferences a user pointer:
>
> static int bpf_test_finish(union bpf_attr __user *uattr, const void *data,
> 			   u32 size, u32 retval, u32 duration)
> {
> 	void __user *data_out = u64_to_user_ptr(uattr->test.data_out);
>                                                 ^^^^^^^^^^^^^^^^^^^^
> Which of course doesn't work so well :-)
>
> I really wish that didn't silently work on x86/x86_64.

argh. my bad.
I'll send a patch first thing tomorrow unless Daniel beats me to it.
We have kattr there as well which has the whole bpf_attr copied into
kernel memory already. Should have taken data_out from there and
passed into bpf_test_finish().
