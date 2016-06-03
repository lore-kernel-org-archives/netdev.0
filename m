From: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Subject: RE: [bug discuss] fjes driver call trace warning, "PNP0C02" used in
 fjes	seems like a bug,
Date: Fri, 3 Jun 2016 09:58:47 +0000
Message-ID: <EE11001F9E5DDD47B7634E2F8A612F2E1F76DB68@lhreml507-mbx>
References: <57515004.1080301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linuxarm <linuxarm@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "liudongdong (C)" <liudongdong3@huawei.com>,
	"izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:2312 "EHLO
	lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbcFCJ7K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 05:59:10 -0400
In-Reply-To: <57515004.1080301@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dongdong

Thanks for flagging this

+to: Taku Izumi <izumi.taku@jp.fujitsu.com>

Gab

> -----Original Message-----
> From: linuxarm-bounces@huawei.com [mailto:linuxarm-bounces@huawei.com]
> On Behalf Of Dongdong Liu
> Sent: 03 June 2016 10:38
> To: netdev@vger.kernel.org
> Cc: Linuxarm
> Subject: [bug discuss] fjes driver call trace warning, "PNP0C02" used
> in fjes seems like a bug,
> 
> Hi all:
> 
> The bug is recorded in https://bugs.linaro.org/show_bug.cgi?id=2292.
> 
> "PNP0C02" attached two modules drivers/pnp/system.c and
> drivers/net/fjes/fjes_main.c .
> "fjes" driver lead to the call trace.
> 
> system.c:
> static const struct pnp_device_id pnp_dev_table[] = {
>          /* General ID for reserving resources */
>          {"PNP0c02", 0},
>          /* memory controller */
>          {"PNP0c01", 0},
>          {"", 0}
> };
> 
> jes_main.c:
> static const struct acpi_device_id fjes_acpi_ids[] = {
>          {"PNP0C02", 0},
>          {"", 0},
> };
> 
> Both of the modules use id "PNP0C02" (case insensitive),
> 
> I used "PNP0C02" to mark motherboard reserved resource as below in
> UEFI.
> Device (RES1)
> {
> 	Name (_HID, "HISI0081") // HiSi PCIe RC config baseaddress
> 	Name (_CID, "PNP0C02") // Motherboard reserved resource
> 		Name (_CRS, ResourceTemplate (){
> 			Memory32Fixed (ReadWrite, 0xb0080000 , 0x10000)
> 		})
> }
> 
> I think that "PNP0C02" should be used to mark any motherboard reserved
> resource and not a specific network driver.
> It seems like a bug in the "fjes" driver.
> 
> Thanks
> 
> Dongdong
> 
> 
> 
> 
> _______________________________________________
> linuxarm mailing list
> linuxarm@huawei.com
> http://rnd-openeuler.huawei.com/mailman/listinfo/linuxarm
