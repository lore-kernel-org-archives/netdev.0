From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] macvlan: delay the header check for dodgy packets
 into lower device
Date: Thu, 27 Nov 2014 13:14:28 +0800
Message-ID: <5476B334.1050706@redhat.com>
References: <1416993674-11177-1-git-send-email-jasowang@redhat.com> <20141126.153736.1815789848350571029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, vyasevic@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141126.153736.1815789848350571029.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/27/2014 04:37 AM, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed, 26 Nov 2014 17:21:14 +0800
>
>> We do header check twice for a dodgy packet. One is done before
>> macvlan_start_xmit(), another is done before lower device's
>> ndo_start_xmit(). The first one seems redundant so this patch tries to
>> delay header check until a packet reaches its lower device (or macvtap)
>> through always enabling NETIF_F_GSO_ROBUST for macvlan device.
>>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>
> Hmmm, it's the idea that if we have a dodgy packet, we want to
> notice that as early as possible in the packet processing path?
>

Not late even with this patch. The check will be done immediately after 
macvlan passing a packet to lower device which should be sufficient.

For good packets, this patch saves one time of header checking. For bad 
packets, this patch just lets the dropping happens during the validation 
before ndo_start_xmit() of lower device.
