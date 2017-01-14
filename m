From: David VomLehn <vomlehn@texas.net>
Subject: Re: [PATCH v5 01/13] net: ethernet: aquantia: Make and configuration
 files.
Date: Sat, 14 Jan 2017 10:42:30 -0800
Message-ID: <5a7c1fcc-2bb7-f41f-e136-8072efca7307@texas.net>
References: <cover.1484283610.git.vomlehn@texas.net>
 <fe1664e502d28bcb6a5689787b8000e6c9288307.1484283610.git.vomlehn@texas.net>
 <f98434b6-1ff5-6959-6591-b28e24307557@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda2.aus1.datafoundry.com ([209.99.124.133]:34101 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751184AbdANSme (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 13:42:34 -0500
In-Reply-To: <f98434b6-1ff5-6959-6591-b28e24307557@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, we did have it that way at one point. But...there is also the 
kernel philosophy of not putting in something for future expansion; you 
can always do it later... Honestly, I've vacillated on this particular one.

On 01/14/2017 10:39 AM, Florian Fainelli wrote:
>
> On 01/12/2017 09:02 PM, Alexander Loktionov wrote:
>> From: David VomLehn <vomlehn@texas.net>
>>
>> Patches to create the make and configuration files.
>>
>> Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
>> Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
>> Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
>> Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
>> Signed-off-by: David M. VomLehn <vomlehn@texas.net>
>> ---
>>   drivers/net/ethernet/aquantia/Kconfig  | 24 +++++++++++++++++++
>>   drivers/net/ethernet/aquantia/Makefile | 42 ++++++++++++++++++++++++++++++++++
>>   drivers/net/ethernet/aquantia/ver.h    | 18 +++++++++++++++
>>   3 files changed, 84 insertions(+)
>>   create mode 100644 drivers/net/ethernet/aquantia/Kconfig
>>   create mode 100644 drivers/net/ethernet/aquantia/Makefile
>>   create mode 100644 drivers/net/ethernet/aquantia/ver.h
>>
>> diff --git a/drivers/net/ethernet/aquantia/Kconfig b/drivers/net/ethernet/aquantia/Kconfig
>> new file mode 100644
>> index 0000000..a74a4c0
>> --- /dev/null
>> +++ b/drivers/net/ethernet/aquantia/Kconfig
>> @@ -0,0 +1,24 @@
>> +#
>> +# aQuantia device configuration
>> +#
>> +
>> +config NET_VENDOR_AQUANTIA
>> +	bool "aQuantia devices"
>> +	default y
>> +	---help---
>> +	  Set this to y if you have an Ethernet network cards that uses the aQuantia
>> +	  chipset.
>> +
>> +	  This option does not build any drivers; it casues the aQuantia
>> +	  drivers that can be built to appear in the list of Ethernet drivers.
>> +
>> +
>> +if NET_VENDOR_AQUANTIA
>> +
>> +config AQTION
>> +	tristate "aQuantia AQtion Support"
>> +	depends on PCI
>> +	---help---
>> +	  This enables the support for the aQuantia AQtion Ethernet card.
>> +
>> +endif # NET_VENDOR_AQUANTIA
>> diff --git a/drivers/net/ethernet/aquantia/Makefile b/drivers/net/ethernet/aquantia/Makefile
>> new file mode 100644
>> index 0000000..e4ae696
>> --- /dev/null
>> +++ b/drivers/net/ethernet/aquantia/Makefile
>> @@ -0,0 +1,42 @@
>> +################################################################################
>> +#
>> +# aQuantia Ethernet Controller AQtion Linux Driver
>> +# Copyright(c) 2014-2017 aQuantia Corporation.
>> +#
>> +# This program is free software; you can redistribute it and/or modify it
>> +# under the terms and conditions of the GNU General Public License,
>> +# version 2, as published by the Free Software Foundation.
>> +#
>> +# This program is distributed in the hope it will be useful, but WITHOUT
>> +# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
>> +# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
>> +# more details.
>> +#
>> +# You should have received a copy of the GNU General Public License along
>> +# with this program. If not, see <http://www.gnu.org/licenses/>.
>> +#
>> +# The full GNU General Public License is included in this distribution in
>> +# the file called "COPYING".
>> +#
>> +# Contact Information: <rdc-drv@aquantia.com>
>> +# aQuantia Corporation, 105 E. Tasman Dr. San Jose, CA 95134, USA
>> +#
>> +################################################################################
>> +
>> +#
>> +# Makefile for the AQtion(tm) Ethernet driver
>> +#
>> +
>> +obj-$(CONFIG_AQTION) += atlantic.o
>> +
>> +atlantic-objs := aq_main.o \
>> +	aq_nic.o \
>> +	aq_pci_func.o \
>> +	aq_vec.o \
>> +	aq_ring.o \
>> +	aq_hw_utils.o \
>> +	aq_ethtool.o \
>> +	hw_atl/hw_atl_a0.o \
>> +	hw_atl/hw_atl_b0.o \
>> +	hw_atl/hw_atl_utils.o \
>> +	hw_atl/hw_atl_llh.o
> You might want to create an aqtion or atlantic folder just in case you
> later on submit a driver for another aquantia NIC. That would keep the
> directory structure clean.


-- 
David VL
