From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf pointer alignment validation
Date: Wed, 10 May 2017 18:21:50 +0200
Message-ID: <59133E1E.8060208@iogearbox.net>
References: <20170510055735.hfkoh4w3xaka5yl5@ast-mbp>   <20170510.113357.362211347006868605.davem@davemloft.net>        <59133716.7060800@iogearbox.net> <20170510.115720.1396306489898364855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, ast@fb.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44125 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932226AbdEJQWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 12:22:03 -0400
In-Reply-To: <20170510.115720.1396306489898364855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 05:57 PM, David Miller wrote:
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

See for example 7f677633379b ("bpf: introduce BPF_F_ALLOW_OVERRIDE
flag"). We can add a flags field to the prog loading part of union
bpf_attr; we would need to make sure to update BPF_PROG_LOAD_LAST_FIELD
to the new member, and to reject unknown flags, of course. Then the
syscall will handle compat with older binaries just fine by design,
the main bpf syscall code and CHECK_ATTR() macros will ensure this
(backward compat, and to a limited degree also forward compat).
