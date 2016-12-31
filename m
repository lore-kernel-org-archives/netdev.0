From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v1 0/2] bpf: add longest prefix match map
Date: Sat, 31 Dec 2016 14:31:36 -0800
Message-ID: <CAADnVQJ63TVkzA+2dUzmdywuMXo5TcwR0WmM0VC++7SShzKrdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Mack <daniel@zonque.org>, Alexei Starovoitov <ast@fb.com>,
        dh.herrmann@gmail.com, Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36339 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754815AbcLaWb7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2016 17:31:59 -0500
Received: by mail-lf0-f50.google.com with SMTP id t196so254110919lff.3
        for <netdev@vger.kernel.org>; Sat, 31 Dec 2016 14:31:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 30, 2016 at 12:25 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Mack <daniel@zonque.org>
> Date: Thu, 29 Dec 2016 18:28:53 +0100
>
>> This patch set adds a longest prefix match algorithm that can be used
>> to match IP addresses to a stored set of ranges. It is exposed as a
>> bpf map type.
>>
>> Internally, data is stored in an unbalanced tree of nodes that has a
>> maximum height of n, where n is the prefixlen the trie was created
>> with.
>>
>> Not that this has nothing to do with fib or fib6 and is in no way meant
>> to replace or share code with it. It's rather a much simpler
>> implementation that is specifically written with bpf maps in mind.
>>
>> Patch 1/2 adds the implementation, and 2/2 an extensive test suite.
>>
>> Feedback is much appreciated.
>
> I'll give Alexei and Daniel time to provide feedback on this series.

I did a quick glance over and, in general, I'm very much in favor.
Will do a proper review Jan 3rd when I'm back from pto.
Daniel,
could you provide performance numbers for lookups per second
for different key lengths with almost empty and almost
full 100k+ lpm rules?
And the rate of updates per second?
I guess your use case is more traditional 32 or 128 bit lpm
whereas I'd like to use it as 64-bit lpm.
Would be good to add few tests with non-power of 8 key length
(it seems to me they should be supported by the algo).
Thank you for working on it!
