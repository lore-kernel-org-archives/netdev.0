From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [PATCH -next] PCI: fix tlan build when CONFIG_PCI is not enabled
Date: Tue, 15 Feb 2011 00:02:59 +0200
Message-ID: <4D59A693.2080106@iki.fi>
References: <20110214181137.ee8d4c08.sfr@canb.auug.org.au> <20110214122750.e1e03bc8.randy.dunlap@oracle.com> <4D599F60.4010800@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-pci@vger.kernel.org,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Jesse Barnes <jbarnes@virtuousgeek.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:60600 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046Ab1BNWCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 17:02:36 -0500
In-Reply-To: <4D599F60.4010800@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sakari Ailus wrote:
> Randy Dunlap wrote:
>> From: Randy Dunlap<randy.dunlap@oracle.com>
>>
>> When CONFIG_PCI is not enabled, tlan.c has a build error:
>> drivers/net/tlan.c:503: error: implicit declaration of function 'pci_wake_from_d3'
>>
>> so add an inline function stub for this function to pci.h when
>> PCI is not enabled, similar to other stubbed PCI functions.
>>
>> Signed-off-by: Randy Dunlap<randy.dunlap@oracle.com>
>> Cc: Sakari Ailus<sakari.ailus@iki.fi>
>
> Hi Randy,
>
> I think this issue in tlan driver was caused by my recent patch which
> added the suspend/resume support to tlan:
>
> <URL:http://marc.info/?l=linux-netdev&m=129564436110754&w=3>
>
> There apparently are tlan cards which are EISA (not PCI) which I forgot
> when writing the patch. The suspend/resume has been only tested with PCI
> as I have no EISA bus (let alone EISA tlan card!).

Right; so I suppose there's no PM support in EISA anyway. Other pci 
functions appear to be no-ops when CONFIG_PCI isn't defined so this 
patch seems right to me --- and no changes are needed in the tlan driver.

Acked-by: Sakari Ailus <sakari.ailus@iki.fi>

-- 
Sakari Ailus
sakari.ailus@iki.fi
