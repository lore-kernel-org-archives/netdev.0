From: Hanjun Guo <guohanjun@huawei.com>
Subject: Re: [bug discuss] fjes driver call trace warning, "PNP0C02" used in
 fjes seems like a bug,
Date: Mon, 6 Jun 2016 17:13:46 +0800
Message-ID: <57553ECA.90701@huawei.com>
References: <57515004.1080301@huawei.com>
 <EE11001F9E5DDD47B7634E2F8A612F2E1F76DB68@lhreml507-mbx>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linuxarm <linuxarm@huawei.com>
To: Gabriele Paoloni <gabriele.paoloni@huawei.com>,
	"liudongdong (C)" <liudongdong3@huawei.com>,
	"izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:63201 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbcFFJOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 05:14:11 -0400
In-Reply-To: <EE11001F9E5DDD47B7634E2F8A612F2E1F76DB68@lhreml507-mbx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/6/3 17:58, Gabriele Paoloni wrote:
> Hi Dongdong
>
> Thanks for flagging this
>
> +to: Taku Izumi <izumi.taku@jp.fujitsu.com>
>
> Gab
>
>> -----Original Message-----
>> From: linuxarm-bounces@huawei.com [mailto:linuxarm-bounces@huawei.com]
>> On Behalf Of Dongdong Liu
>> Sent: 03 June 2016 10:38
>> To: netdev@vger.kernel.org
>> Cc: Linuxarm
>> Subject: [bug discuss] fjes driver call trace warning, "PNP0C02" used
>> in fjes seems like a bug,
>>
>> Hi all:
>>
>> The bug is recorded in https://bugs.linaro.org/show_bug.cgi?id=2292.
>>
>> "PNP0C02" attached two modules drivers/pnp/system.c and
>> drivers/net/fjes/fjes_main.c .
>> "fjes" driver lead to the call trace.
>>
>> system.c:
>> static const struct pnp_device_id pnp_dev_table[] = {
>>          /* General ID for reserving resources */
>>          {"PNP0c02", 0},
>>          /* memory controller */
>>          {"PNP0c01", 0},
>>          {"", 0}
>> };
>>
>> jes_main.c:
>> static const struct acpi_device_id fjes_acpi_ids[] = {
>>          {"PNP0C02", 0},
>>          {"", 0},
>> };
>>
>> Both of the modules use id "PNP0C02" (case insensitive),
>>
>> I used "PNP0C02" to mark motherboard reserved resource as below in
>> UEFI.
>> Device (RES1)
>> {
>> 	Name (_HID, "HISI0081") // HiSi PCIe RC config baseaddress
>> 	Name (_CID, "PNP0C02") // Motherboard reserved resource
>> 		Name (_CRS, ResourceTemplate (){
>> 			Memory32Fixed (ReadWrite, 0xb0080000 , 0x10000)
>> 		})
>> }
>>
>> I think that "PNP0C02" should be used to mark any motherboard reserved
>> resource and not a specific network driver.
>> It seems like a bug in the "fjes" driver.

I agree,  PNP0C02 is not a valid ACPI device HID but only for reserved resources.

Thanks
Hanjun
