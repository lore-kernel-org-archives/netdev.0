From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v1 net-next] net: filter: fix length calculation in BPF testsuite
Date: Fri, 30 May 2014 10:15:11 -0700
Message-ID: <CA+ZOOTOOLkx=2Vzcn+2_3AX=D3txvFB56z8shKtF91K6zmUoSw@mail.gmail.com>
References: <1401391757-27620-1-git-send-email-chema@google.com>
	<53879B78.5050106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:32813 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964810AbaE3RPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 13:15:13 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so1090450igd.2
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 10:15:11 -0700 (PDT)
In-Reply-To: <53879B78.5050106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 1:41 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 05/29/2014 09:29 PM, Chema Gonzalez wrote:
>>
>> The current probe_filter_length() (the function that calculates the
>> length of a test BPF filter) behavior is to declare the end of the
>> filter as soon as it finds {0, *, *, 0}. This is actually a valid
>> insn ("ld #0"), so any filter with includes "BPF_STMT(BPF_LD | BPF_IMM,
>> 0)"
>> fails (its length is cut short).
>>
>> We are changing probe_filter_length() so as to start from the end, and
>> declare the end of the filter as the first instruction which is not
>> {0, *, *, 0}. This solution produces a simpler patch than the
>> alternative of using an explicit end-of-filter mark. It is technically
>> incorrect if your filter ends up with "ld #0", but that should not
>> happen anyway.
>>
>> We also add a new test (LD_IMM_0) that includes ld #0 (does not work
>> without this patch).
>>
>> Signed-off-by: Chema Gonzalez <chema@google.com>
>
>
> Looks good to me, thanks a lot Chema!
>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
>
>
>> +       for (len = MAX_INSNS-1; len > 0; --len)
>> +               if (fp[len].code != 0 || fp[len].k != 0)
>> +                       break;
>>
>> -       return len;
>> +       return len+1;
>
>
> Nit: would be great to have a whitespace between MAX_INSNS-1 and len+1 but
> that shouldn't matter that much, perhaps.
Done.

-Chema
