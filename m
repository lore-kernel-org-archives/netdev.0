From: Dongdong Liu <liudongdong3@huawei.com>
Subject: [bug discuss] fjes driver call trace warning, "PNP0C02" used in fjes
 seems like a bug,
Date: Fri, 3 Jun 2016 17:38:12 +0800
Message-ID: <57515004.1080301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="gbk"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linuxarm <linuxarm@huawei.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:13716 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbcFCJib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 05:38:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all:

The bug is recorded in https://bugs.linaro.org/show_bug.cgi?id=2292.

"PNP0C02" attached two modules drivers/pnp/system.c and drivers/net/fjes/fjes_main.c .
"fjes" driver lead to the call trace.

system.c:
static const struct pnp_device_id pnp_dev_table[] = {
         /* General ID for reserving resources */
         {"PNP0c02", 0},
         /* memory controller */
         {"PNP0c01", 0},
         {"", 0}
};

jes_main.c:
static const struct acpi_device_id fjes_acpi_ids[] = {
         {"PNP0C02", 0},
         {"", 0},
};

Both of the modules use id "PNP0C02" (case insensitive),

I used "PNP0C02" to mark motherboard reserved resource as below in UEFI.
Device (RES1)
{
	Name (_HID, "HISI0081") // HiSi PCIe RC config baseaddress
	Name (_CID, "PNP0C02") // Motherboard reserved resource
		Name (_CRS, ResourceTemplate (){
			Memory32Fixed (ReadWrite, 0xb0080000 , 0x10000)
		})
}

I think that "PNP0C02" should be used to mark any motherboard reserved resource and not a specific network driver.
It seems like a bug in the "fjes" driver.

Thanks

Dongdong
