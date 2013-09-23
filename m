From: Jason Wang <jasowang@redhat.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: convert to GRO API
 and advertise this feature
Date: Mon, 23 Sep 2013 13:02:05 +0800
Message-ID: <523FCB4D.30801@redhat.com>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>	<523E8E3B.3050805@redhat.com>	<20130922120936.GA4079@zion.uk.xensource.com> <9C83E3AC-719D-4290-8C19-A06356C4BFFA@juniper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	"<xen-devel@lists.xen.org>" <xen-devel@lists.xen.org>
To: Anirban Chakraborty <abchak@juniper.net>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64176 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944Ab3IWFCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 01:02:15 -0400
In-Reply-To: <9C83E3AC-719D-4290-8C19-A06356C4BFFA@juniper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2013 07:04 AM, Anirban Chakraborty wrote:
> On Sep 22, 2013, at 5:09 AM, Wei Liu <wei.liu2@citrix.com> wrote:
>
>> On Sun, Sep 22, 2013 at 02:29:15PM +0800, Jason Wang wrote:
>>> On 09/22/2013 12:05 AM, Wei Liu wrote:
>>>> Anirban was seeing netfront received MTU size packets, which downgraded
>>>> throughput. The following patch makes netfront use GRO API which
>>>> improves throughput for that case.
>>>>
>>>> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
>>>> Signed-off-by: Anirban Chakraborty <abchak@juniper.net>
>>>> Cc: Ian Campbell <ian.campbell@citrix.com>
>>> Maybe a dumb question: doesn't Xen depends on the driver of host card to
>>> do GRO and pass it to netfront? What the case that netfront can receive
>> The would be the ideal situation. Netback pushes large packets to
>> netfront and netfront sees large packets.
>>
>>> a MTU size packet, for a card that does not support GRO in host? Doing
>> However Anirban saw the case when backend interface receives large
>> packets but netfront sees MTU size packets, so my thought is there is
>> certain configuration that leads to this issue. As we cannot tell
>> users what to enable and what not to enable so I would like to solve
>> this within our driver.
>>
>>> GRO twice may introduce extra overheads.
>>>
>> AIUI if the packet that frontend sees is large already then the GRO path
>> is quite short which will not introduce heavy penalty, while on the
>> other hand if packet is segmented doing GRO improves throughput.
>>
> Thanks Wei, for explaining and submitting the patch. I would like add following to what you have already mentioned.
> In my configuration, I was seeing netback was pushing large packets to the guest (Centos 6.4) but the netfront was receiving MTU sized packets. With this patch on, I do see large packets received on the guest interface. As a result there was substantial throughput improvement in the guest side (2.8 Gbps to 3.8 Gbps). Also, note that the host NIC driver was enabled for GRO already. 
>
> -Anirban

In this case, even if you still want to do GRO. It's better to find the
root cause of why the GSO packet were segmented (maybe GSO were not
enabled for netback?), since it introduces extra overheads.
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
