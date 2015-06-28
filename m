From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC net-next] vxlan: GRO support at tunnel layer
Date: Sun, 28 Jun 2015 14:31:00 -0700
Message-ID: <CALx6S35joR=WtiqXne-vkMB+R0e=4pWo2r_WiKASGQcViBsAFA@mail.gmail.com>
References: <1435360189-641007-1-git-send-email-tom@herbertland.com>
	<558DF24A.1040504@hp.com>
	<df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rick Jones <rick.jones2@hp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35928 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbbF1VbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 17:31:01 -0400
Received: by iecvh10 with SMTP id vh10so104065928iec.3
        for <netdev@vger.kernel.org>; Sun, 28 Jun 2015 14:31:00 -0700 (PDT)
In-Reply-To: <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 28, 2015 at 10:20 AM, Ramu Ramamurthy
<sramamur@linux.vnet.ibm.com> wrote:
> On 2015-06-26 17:46, Rick Jones wrote:
>>
>> On 06/26/2015 04:09 PM, Tom Herbert wrote:
>>>
>>> Add calls to gro_cells infrastructure to do GRO when receiving on a
>>> tunnel.
>>>
>>> Testing:
>>>
>>> Ran 200 netperf TCP_STREAM instance
>>>
>>> - With fix (GRO enabled on VXLAN interface)
>>>
>>>    Verify GRO is happening.
>>>
>>>    9084 MBps tput
>>>    3.44% CPU utilization
>>>
>>> - Without fix (GRO disabled on VXLAN interface)
>>>
>>>    Verified no GRO is happening.
>>>
>>>    9084 MBps tput
>>>    5.54% CPU utilization
>>
>>
>> This has been an area of interest so:
>>
>> Tested-by: Rick Jones <rick.jones2@hp.com>
>>
>> Some single-stream results between two otherwise identical systems
>> with 82599ES NICs in them, one running a 4.1.0-rc1+ kernel from a
>> davem tree from a while ago, the other running 4.1.0+ from a davem
>> tree pulled yesterday upon which I've applied the patch.
>>
>> Netperf command used:
>>
>> netperf -l 30 -H <IP> -t TCP_MAERTS -c -- -O
>> throughput,local_cpu_util,local_cpu_peak_util,local_cpu_peak_id,local_sd
>>
>> First, inbound to the unpatched system from the patched:
>>
>>
>> MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 192.168.0.21 () port 0 AF_INET : demo
>> Throughput Local Local   Local   Local
>>            CPU   Peak    Peak    Service
>>            Util  Per CPU Per CPU Demand
>>            %     Util %  ID
>> 5487.42    6.01  99.83   0       2.872
>> 5580.83    6.20  99.16   0       2.911
>> 5445.52    5.68  98.92   0       2.734
>> 5653.36    6.24  99.80   0       2.891
>> 5187.56    5.66  97.41   0       2.858
>>
>> Second, inbound to the patched system from the unpatched:
>>
>> MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
>> 192.168.0.22 () port 0 AF_INET : demo
>> Throughput Local Local   Local   Local
>>            CPU   Peak    Peak    Service
>>            Util  Per CPU Per CPU Demand
>>            %     Util %  ID
>> 6933.29    3.19  93.67   3       1.208
>> 7031.35    3.34  95.08   3       1.244
>> 7006.28    3.27  94.55   3       1.223
>> 6948.62    3.09  93.20   3       1.165
>> 7007.80    3.22  94.34   3       1.206
>>
>> Comparing the service demands shows a > 50% reduction in overhead.
>
>
> Rick, in your test, are you seeing gro becoming effective on the vxlan
> interface
> with the 82599ES nic ? (ie, tcpdump on the vxlan interface shows larger
> frames
> than the mtu of that interface, and kernel trace shows vxlan_gro_receive()
> being hit)
>
> Throughputs of 5.5 Gbps (or the improved 7Gbs) leads me to suspect that gro
> is still not effective
> in your test on the vxlan interface with the 82588ES nic - Because, when
> vxlan gro became effective with the patch
> I suggested earlier, I could see throughput of ~8.5 Gbps on that nic.
>
You're comparing apples to oranges. Please test the patch in your
environment I posted and report results. Please also test with
multiple connections, single connection performance can be misleading
and does not really reflect what real production servers are doing.

Tom

>
