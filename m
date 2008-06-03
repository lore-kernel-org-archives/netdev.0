From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 03 Jun 2008 14:43:28 +0200
Message-ID: <48453C70.1040303@trash.net>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl> <20080603113343.GA4714@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38893 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbYFCMnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:43:32 -0400
In-Reply-To: <20080603113343.GA4714@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Jun 03, 2008 at 12:37:35PM +0200, Krzysztof Oledzki wrote:
>>
> If such an old app uses rtm_table, this 253 table could be used for
> something and get additional entries after this patch. Another case
> would be when such an overflow on 0xff is "expected", then old tables
> would loose their entries. I hope I'm wrong with this, but it looks
> like admins can do strange things, and then this would be called a
> regression. So, I think this patch is right if we are sure there are
> no such cases...
> 
>>> BTW, I wonder, how these old appliction would treat RT_TABLE_UNSPEC  
>>> instead.
>> Such old appliction is for example zebra/quagga: it asks for all routes,  
>> does not know about RTA_TABLE so uses rtm_table and selects all entries  
>> with rtm_table == RT_TABLE_MAIN or zebrad.rtm_table_default which is  
>> unfortunately 0 by default. So no, RT_TABLE_UNSPEC (0) does not help, 
>> even makes everythink worse here.
> 
> I see: so we don't care for these RT_TABLE_COMPAT entries, let only
> they don't go to _MAIN or _UNSPEC!

Well, if people already use table 253, I guess they might care.
I'm not convinced this is any better than overflowing.

Quoting the changelog from the patch which introduces this:

     Introduce RTA_TABLE route attribute and FRA_TABLE routing rule 
attribute
     to hold 32 bit routing table IDs. Usespace compatibility is provided by
     continuing to accept and send the rtm_table field, but because of its
     limited size it can only carry the low 8 bits of the table ID. This
     implies that if larger IDs are used, _all_ userspace programs using 
them
     need to use RTA_TABLE.

And I still don't see any other way to handle this properly.
