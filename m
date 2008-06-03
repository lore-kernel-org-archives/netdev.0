From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 11:33:43 +0000
Message-ID: <20080603113343.GA4714@ff.dom.local>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:54179 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbYFCL3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 07:29:49 -0400
Received: by ug-out-1314.google.com with SMTP id h2so65591ugf.16
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 04:29:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 12:37:35PM +0200, Krzysztof Oledzki wrote:
>
>
> On Tue, 3 Jun 2008, Jarek Poplawski wrote:
>
>> On 03-06-2008 00:09, Krzysztof Oledzki wrote:
>>> From 4cb8c341fc444afc638cf9ce4efb7e4248e88b5e Mon Sep 17 00:00:00 2001
>>> From: Krzysztof Piotr Oledzki <ole@ans.pl>
>>> Date: Tue, 3 Jun 2008 00:03:41 +0200
>>> Subject: [NET] Fix routing tables with id > 255 for legacy software
>>>
>>> Most legacy software do not like tables > 255 as rtm_table is u8
>>> so tb_id is sent &0xff and it is possible to mismatch for example
>>> table 510 with table 254 (main).
>>>
>>> This patch introduces RT_TABLE_COMPAT=253 so the code uses it if
>>> tb_id > 255. It makes such old applications happy, new
>>> ones are still able to use RTA_TABLE to get a proper table id.
>>>
>>
>> Probably, as usual, some people will grumble this breaks their scripts,
>> so, probably, some if or ifdef is needed?
> Why? If scripts are based on a recent version of iproute2 that uses  
> RTA_TABLE then everything should work, especially there is no way to use  
> tables with id > 255 with old iproute2.

If such an old app uses rtm_table, this 253 table could be used for
something and get additional entries after this patch. Another case
would be when such an overflow on 0xff is "expected", then old tables
would loose their entries. I hope I'm wrong with this, but it looks
like admins can do strange things, and then this would be called a
regression. So, I think this patch is right if we are sure there are
no such cases...

>
>> BTW, I wonder, how these old appliction would treat RT_TABLE_UNSPEC  
>> instead.
>
> Such old appliction is for example zebra/quagga: it asks for all routes,  
> does not know about RTA_TABLE so uses rtm_table and selects all entries  
> with rtm_table == RT_TABLE_MAIN or zebrad.rtm_table_default which is  
> unfortunately 0 by default. So no, RT_TABLE_UNSPEC (0) does not help, 
> even makes everythink worse here.

I see: so we don't care for these RT_TABLE_COMPAT entries, let only
they don't go to _MAIN or _UNSPEC!

Thanks for the explanation,
Jarek P.
