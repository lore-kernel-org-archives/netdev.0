From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next/mmotm] net/can: fix softing build errors
Date: Sat, 12 Feb 2011 08:02:42 -0800
Message-ID: <4D56AF22.4070803@oracle.com>
References: <201102110100.p1B10sDx029244@imap1.linux-foundation.org> <20110211223312.be571303.randy.dunlap@oracle.com> <20110212111344.GA328@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:34572 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab1BLQED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 11:04:03 -0500
In-Reply-To: <20110212111344.GA328@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/11 03:15, Kurt Van Dijck wrote:
> On Fri, Feb 11, 2011 at 10:33:12PM -0800, Randy Dunlap wrote:
>>
>> warning: (CAN_SOFTING_CS) selects CAN_SOFTING which has unmet direct dependencies (NET && CAN && CAN_DEV && HAS_IOMEM)
>>
>> with this partial config:
>>
>> CONFIG_CAN=m
>> # CONFIG_CAN_RAW is not set
>> # CONFIG_CAN_BCM is not set
>> # CAN Device Drivers
>> # CONFIG_CAN_VCAN is not set
>> CONFIG_CAN_SLCAN=m
>> # CONFIG_CAN_DEV is not set
>> CONFIG_CAN_SOFTING=m
>> CONFIG_CAN_SOFTING_CS=m
>> # CONFIG_CAN_DEBUG_DEVICES is not set
> I understand the output, but I don't understand the cause well enough.
> CAN_SOFTING=m has a 'depends on CAN_DEV'
> Is it then possible to have CAN_SOFTING=m _and not_ CAN_DEV ?

Yes.  From Documentation/kbuild/kconfig-language.txt:

  Note:
	select should be used with care. select will force
	a symbol to a value without visiting the dependencies.
	By abusing select you are able to select a symbol FOO even
	if FOO depends on BAR that is not set.
	In general use select only for non-visible symbols
	(no prompts anywhere) and for symbols with no dependencies.
	That will limit the usefulness but on the other hand avoid
	the illegal configurations all over.


CAN_SOFTING_CS does not depend on CAN_DEV. but it selects CAN_SOFTING,
which does depend on CAN_DEV, ... but CAN_DEV is not enabled.


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
