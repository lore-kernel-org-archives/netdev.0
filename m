From: "Sujith Sankar (ssujith)" <ssujith@cisco.com>
Subject: Re: [PATCH net-next v3 04/19] net: enic: slight optimization of
 addr compare
Date: Thu, 2 Jan 2014 04:09:34 +0000
Message-ID: <CEEAE3A2.F048%ssujith@cisco.com>
References: <alpine.LNX.2.03.1312301341050.2286@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Christian Benvenuti (benve)" <benve@cisco.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	"Neel Patel (neepatel)" <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Govindarajulu Varadarajan (gvaradar)" <gvaradar@cisco.com>,
	Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.03.1312301341050.2286@cisco.com>
Content-Language: en-US
Content-ID: <E3F34113E20C68468652600BA841AB95@emea.cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks good.

Acked by: Sujith Sankar <ssujith@cisco.com>


On 30/12/13 1:42 PM, "Govindarajulu Varadarajan (gvaradar)"
<gvaradar@cisco.com> wrote:

>On Mon, 30 Dec 2013, Ding Tianhong wrote:
>
>> Use possibly more efficient ether_addr_equal
>> to instead of memcmp.
>>
>> Cc: Christian Benvenuti <benve@cisco.com>
>> Cc: Sujith Sankar <ssujith@cisco.com>
>> Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
>> Cc: Neel Patel <neepatel@cisco.com>
>> Cc: Nishank Trivedi <nistrive@cisco.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/ethernet/cisco/enic/enic_pp.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/cisco/enic/enic_pp.c
>>b/drivers/net/ethernet/cisco/enic/enic_pp.c
>> index 43464f0..e6a8319 100644
>> --- a/drivers/net/ethernet/cisco/enic/enic_pp.c
>> +++ b/drivers/net/ethernet/cisco/enic/enic_pp.c
>> @@ -162,7 +162,7 @@ static int enic_are_pp_different(struct
>>enic_port_profile *pp1,
>> 	return strcmp(pp1->name, pp2->name) | !!memcmp(pp1->instance_uuid,
>> 		pp2->instance_uuid, PORT_UUID_MAX) |
>> 		!!memcmp(pp1->host_uuid, pp2->host_uuid, PORT_UUID_MAX) |
>> -		!!memcmp(pp1->mac_addr, pp2->mac_addr, ETH_ALEN);
>> +		!ether_addr_equal(pp1->mac_addr, pp2->mac_addr);
>> }
>>
>> static int enic_pp_preassociate(struct enic *enic, int vf,
>> -- 
>> 1.8.0
>>
>
>looks good for me
>
>Acked-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
