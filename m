From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 03 Jun 2008 15:10:13 +0200
Message-ID: <484542B5.4070401@trash.net>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl> <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net> <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39844 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965AbYFCNKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 09:10:15 -0400
In-Reply-To: <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:
> On Tue, 3 Jun 2008, Patrick McHardy wrote:
> 
>> Well, if people already use table 253, I guess they might care.
> 
> Not really as if pople use a FRA_TABLE aware application they should not 
> notice any difference.

In that case not of course.

>> I'm not convinced this is any better than overflowing.
> 
> But if they use FRA_TABLE unaware application than overflowing means 
> mismatching all:
>  - N*256 table as RT_TABLE_UNSPEC
>  - N*256+253 tables as RT_TABLE_DEFAULT
>  - N*256+254 tables as RT_TABLE_MAIN
>  - N*256+255 tables as RT_TABLE_LOCAL
> 
> And as I just find out, when it happens is quite unexpected and can 
> really hurt. :(
> 
>> And I still don't see any other way to handle this properly.
> 
> Exactly. So that's why I came with above solution, similar to AS_TRANSIT 
> idea used in BGP to handle 16bit -> 32bit ASN transformation.

I think the proper solution is what I wrote in the changelog
entry: fix userspace applications when using extended table
IDs.

Your patch makes it more predictable, so I'm not completely
opposed, but still its just a workaround.
