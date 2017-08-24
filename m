From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: netdev is never null in __dev_map_flush
Date: Thu, 24 Aug 2017 10:34:49 +0200
Message-ID: <599E8FA9.4000804@iogearbox.net>
References: <d8e0306b70b05bdd5e628459863d1027c8c26959.1503537400.git.daniel@iogearbox.net> <1efe2357-43aa-8976-75a0-62d4572287cc@fb.com> <599E4397.5020802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
        Alexei Starovoitov <ast@fb.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49433 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751215AbdHXIez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 04:34:55 -0400
In-Reply-To: <599E4397.5020802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2017 05:10 AM, John Fastabend wrote:
> On 08/23/2017 06:25 PM, Alexei Starovoitov wrote:
>> On 8/23/17 6:20 PM, Daniel Borkmann wrote:
>>> No need to test for it in fast-path, every dev in bpf_dtab_netdev
>>> is guaranteed to be non-NULL, otherwise dev_map_update_elem() will
>>> fail in the first place.
>>>
>>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>>
>> wow. interesting. I'm surprised you see a difference from
>> such micro-optimization.
>> Acked-by: Alexei Starovoitov <ast@kernel.org>
>
> Thanks for the clean up, I was a bit over paranoid here as well. Is
> this actually noticeable in pps benchmark or just making the code
> cleaner? Just curious.

No, just from going over the code wondering why it could be
null here but not elsewhere.
