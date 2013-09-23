From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: convert to GRO API
 and advertise this feature
Date: Mon, 23 Sep 2013 14:22:28 +0800
Message-ID: <523FDE24.5060902@oracle.com>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>	<523E8E3B.3050805@redhat.com>	<20130922120936.GA4079@zion.uk.xensource.com> <9C83E3AC-719D-4290-8C19-A06356C4BFFA@juniper.net> <523FCB4D.30801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anirban Chakraborty <abchak@juniper.net>,
	Wei Liu <wei.liu2@citrix.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	"<xen-devel@lists.xen.org>" <xen-devel@lists.xen.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17399 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab3IWGWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 02:22:41 -0400
In-Reply-To: <523FCB4D.30801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-9-23 13:02, Jason Wang wrote:
> On 09/23/2013 07:04 AM, Anirban Chakraborty wrote:
>> On Sep 22, 2013, at 5:09 AM, Wei Liu <wei.liu2@citrix.com> wrote:
>>
>>> On Sun, Sep 22, 2013 at 02:29:15PM +0800, Jason Wang wrote:
>>>> On 09/22/2013 12:05 AM, Wei Liu wrote:
>>>>> Anirban was seeing netfront received MTU size packets, which downgraded
>>>>> throughput. The following patch makes netfront use GRO API which
>>>>> improves throughput for that case.
>>>>>
>>>>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>>>>> Signed-off-by: Anirban Chakraborty <abchak@juniper.net>
>>>>> Cc: Ian Campbell <ian.campbell@citrix.com>
>>>> Maybe a dumb question: doesn't Xen depends on the driver of host card to
>>>> do GRO and pass it to netfront? What the case that netfront can receive
>>> The would be the ideal situation. Netback pushes large packets to
>>> netfront and netfront sees large packets.
>>>
>>>> a MTU size packet, for a card that does not support GRO in host? Doing
>>> However Anirban saw the case when backend interface receives large
>>> packets but netfront sees MTU size packets, so my thought is there is
>>> certain configuration that leads to this issue. As we cannot tell
>>> users what to enable and what not to enable so I would like to solve
>>> this within our driver.
>>>
>>>> GRO twice may introduce extra overheads.
>>>>
>>> AIUI if the packet that frontend sees is large already then the GRO path
>>> is quite short which will not introduce heavy penalty, while on the
>>> other hand if packet is segmented doing GRO improves throughput.
>>>
>> Thanks Wei, for explaining and submitting the patch. I would like add following to what you have already mentioned.
>> In my configuration, I was seeing netback was pushing large packets to the guest (Centos 6.4) but the netfront was receiving MTU sized packets. With this patch on, I do see large packets received on the guest interface. As a result there was substantial throughput improvement in the guest side (2.8 Gbps to 3.8 Gbps). Also, note that the host NIC driver was enabled for GRO already.
>>
>> -Anirban
> In this case, even if you still want to do GRO. It's better to find the
> root cause of why the GSO packet were segmented

Totally agree, we need to find the cause why large packets is segmented 
only in different host case.

> (maybe GSO were not
> enabled for netback?), since it introduces extra overheads.

 From Anirban's feedback, large packets can be seen on vif interface, 
and even on guests running on the same host.

Thanks
Annie
