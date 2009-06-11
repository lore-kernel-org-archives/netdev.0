From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [PATCH] mlx4_en: added pci_device_id table
Date: Thu, 11 Jun 2009 17:40:05 +0300
Message-ID: <4A311745.50505@mellanox.co.il>
References: <4A2E5B5B.7060701@mellanox.co.il> <20090611.030527.14497101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43059 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750736AbZFKNtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 09:49:36 -0400
In-Reply-To: <20090611.030527.14497101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> Date: Tue, 09 Jun 2009 15:53:47 +0300
> 
>> This is required to ensure that mlx4_en module loads on boot when
>> there are ConnectX devices installed.
>> The driver is compound from two modules: mlx4_core, the low level module
>> and mlx4_en. Currently mlx4_core is the only module that is loaded on boot,
>> this is not enough to enable the ConnectX Ethernet interfaces.
>>
>> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> 
> This is pretty ugly.
> 
> Two modules with the same exact module ID table smells like bad
> design.  I see no harm in you combining all of this code into one
> final module object.
> 

I can make some changes like defining the table once and both the modules using the same table.

As for combining the modules, it is not something we would like to do.
mlx4_en module is not the only "customer" of mlx4_core, there is also mlx4_ib and mlx4_fc (in the near future).
According to our design, the mlx4_core module is protocol independent and gives services (like command interface and HW
resources management) to the modules mentioned above.

Roland, what do you think? 
