From: Matan Barak <matanb@mellanox.com>
Subject: Re: [PATCH net-next V2 09/12] net/mlx5_core: Make ipv4/ipv6 location
 more clear
Date: Mon, 11 Jan 2016 15:06:16 +0200
Message-ID: <5693A8C8.2050100@mellanox.com>
References: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
 <1452415189-27950-10-git-send-email-ogerlitz@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC1ECF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Moni Shoua <monis@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>,
	'Or Gerlitz' <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0060.outbound.protection.outlook.com ([157.56.112.60]:54498
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760079AbcAKQjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 11:39:33 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCC1ECF@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 1/11/2016 2:17 PM, David Laight wrote:
> From: Or Gerlitz
>> Sent: 10 January 2016 08:40
>> Change the mlx5 firmware interface header to make it
>> more clear which bytes should be used by IPv4 or
>> IPv6 addresses.
>>
>> Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
>> Signed-off-by: Moni Shoua <monis@mellanox.com>
>> Signed-off-by: Matan Barak <matanb@mellanox.com>
>> ---
>>   include/linux/mlx5/mlx5_ifc.h | 20 ++++++++++++++++++--
>>   1 file changed, 18 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
>> index 7f16695..68d73f8 100644
>> --- a/include/linux/mlx5/mlx5_ifc.h
>> +++ b/include/linux/mlx5/mlx5_ifc.h
>> @@ -298,6 +298,22 @@ struct mlx5_ifc_odp_per_transport_service_cap_bits {
>>   	u8         reserved_1[0x1a];
>>   };
>>
>> +struct mlx5_ifc_ipv4_layout_bits {
>> +	u8         reserved_0[0x60];
>> +
>> +	u8         ipv4[0x20];
>> +};
>> +
>> +struct mlx5_ifc_ipv6_layout_bits {
>> +	u8         ipv6[16][0x8];
>> +};
>> +
>> +union mlx5_ifc_ipv6_layout_ipv4_layout_auto_bits {
>> +	struct mlx5_ifc_ipv6_layout_bits ipv6_layout;
>> +	struct mlx5_ifc_ipv4_layout_bits ipv4_layout;
>> +	u8         reserved_0[0x80];
>> +};
>
> I like the way these names just roll off the tongue :-)
>
>> +
>>   struct mlx5_ifc_fte_match_set_lyr_2_4_bits {
>>   	u8         smac_47_16[0x20];
>>
>> @@ -328,9 +344,9 @@ struct mlx5_ifc_fte_match_set_lyr_2_4_bits {
>>   	u8         udp_sport[0x10];
>>   	u8         udp_dport[0x10];
>>
>> -	u8         src_ip[4][0x20];
>> +	union mlx5_ifc_ipv6_layout_ipv4_layout_auto_bits src_ipv4_src_ipv6;
>>
>> -	u8         dst_ip[4][0x20];
>> +	union mlx5_ifc_ipv6_layout_ipv4_layout_auto_bits dst_ipv4_dst_ipv6;
>>   };
>
> Have you considered just how long the line of code to access these
> fields will be?
> It might be better to do (I think it compiles):
> 	union {
> 		u8	src_ipv6[16][0x8];
> 		struct {
> 			u8	src_ipv4_pad[0x60];
> 			u8	src_ipv4[0x20];
> 		}
> 	};
> Repeated for the 'dst' addresses.
> Then fixup the definition of src_ipv4[] (and probably src_ipv6[]) to
> be much clearer about how the addresses are supplied.
>

This is actually created automatically, but I fully agree the names here 
look odd (to say the least). We'll of course fix that :)
Thanks for taking a look.

> 	David
>

Regards,
Matan
