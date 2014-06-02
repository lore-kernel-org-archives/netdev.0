From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] net: filter: fix length calculation in BPF testsuite
Date: Sun, 1 Jun 2014 23:33:16 -0700
Message-ID: <CAMEtUuzw8CzUvaNi_OxaChXK0GKVxy5yaK5ztauRf8eiavzGkw@mail.gmail.com>
References: <53879B78.5050106@redhat.com>
	<1401470112-3933-1-git-send-email-chema@google.com>
	<538A2BCE.7070805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chema Gonzalez <chema@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:60935 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbaFBGdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 02:33:17 -0400
Received: by mail-wi0-f171.google.com with SMTP id cc10so3907675wib.16
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 23:33:16 -0700 (PDT)
In-Reply-To: <538A2BCE.7070805@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 31, 2014 at 12:21 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 05/30/2014 07:15 PM, Chema Gonzalez wrote:
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

Thank you for addressing all our comments.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

>
> Thanks (sorry for the delay as I'm currently on travel).
>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
