From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Thu, 21 Mar 2013 18:47:21 +0100
Message-ID: <514B47A9.3080304@redhat.com>
References: <CA+FuTSeN1wXrSP8-piCdnv8MuqgokndSYsiidvdtC=d2tCqcDQ@mail.gmail.com> <1363761764-4374-1-git-send-email-willemb@google.com> <20130320.123344.1566685302188091721.davem@davemloft.net> <20130320.135934.156565403641352244.davem@davemloft.net> <CA+FuTScnkvSZ1U=vmELNEpS4hU62iMV7B2ZDHT8KGAwxCxA-Ng@mail.gmail.com> <514AA946.6020603@redhat.com> <CA+FuTSfkxkbZ8N1Vr2NVmT-8Obd2sGAo2a_Wwv=U-4KPvnLPPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797Ab3CURr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 13:47:26 -0400
In-Reply-To: <CA+FuTSfkxkbZ8N1Vr2NVmT-8Obd2sGAo2a_Wwv=U-4KPvnLPPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2013 06:27 PM, Willem de Bruijn wrote:
> On Thu, Mar 21, 2013 at 2:31 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 03/21/2013 01:07 AM, Willem de Bruijn wrote:
>>> On Wed, Mar 20, 2013 at 1:59 PM, David Miller <davem@davemloft.net> wrote:
>>>>
>>>> From: David Miller <davem@davemloft.net>
>>>> Date: Wed, 20 Mar 2013 12:33:44 -0400 (EDT)
>>>>
>>>>> From: Willem de Bruijn <willemb@google.com>
>>>>> Date: Wed, 20 Mar 2013 02:42:44 -0400
>>>>>
>>>>>> Fix flaky results with PACKET_FANOUT_HASH depending on whether the
>>>>>> two flows hash into the same packet socket or not.
>>>>>>
>>>>>> Also adds tests for PACKET_FANOUT_LB and PACKET_FANOUT_CPU and
>>>>>> replaces the counting method with a packet ring.
>>>>>>
>>>>>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>>>>>
>>>>> Applied, thanks.  I'll retest on my sparc64 box later today.
>>>>
>>>> Unfortunately, it's still broken there:
>>>
>>> This looks like a new problem. Now the counters all stay zero.
>>>
>>> I am looking into it. I have not been able to reproduce this on my
>>> x86_64 so far, so just brought a sparc32 up in qemu. Had less luck
>>> with sparc64, but impressive that it works at all. Come to think of
>>> it, is this a 64-bit kernel with 32-bit userland? Perhaps that
>>> affects packet ring memory layout.
>>
>>
>> That can affect the ring buffer in case of TPACKET_V1, which is default
>> if not specified otherwise. See Documentation/networking/packet_mmap.txt
>> +514
>
> Thanks, Daniel. In that case, the following should fix it.
> Unfortunately, I don't have the hardware to verify, but it still
> passes on my platforms. Let me know if you prefer it as a regular
> patch instead of inline.

I can only tell you about x86_64: [PASS], although two ERRORs:

running psock_fanout test
--------------------
test: control single socket
test: control multiple sockets
test: datapath 0x0
info: count=0,0, expect=0,0
info: count=20,0, expect=15,5
ERROR: incorrect queue lengths
info: count=20,0, expect=20,5
ERROR: incorrect queue lengths
info: trying alternate ports (4)
test: datapath 0x0
[...]
OK. All tests passed
[PASS]
