From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Sun, 20 Jan 2008 00:21:56 +0100
Message-ID: <47928614.1090209@gmail.com>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net>	<478D226E.1050209@gmail.com>	<20080116004602.zn4y94e8sg0w4o8k@mail.bigtelecom.ru> <20080116010459.676cchrf8ko4wk8o@mail.bigtelecom.ru> <478D9222.7030603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: slavon@bigtelecom.ru, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:10469 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbYASXTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 18:19:32 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1445896fga.17
        for <netdev@vger.kernel.org>; Sat, 19 Jan 2008 15:19:31 -0800 (PST)
In-Reply-To: <478D9222.7030603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 01/16/2008 06:12 AM:

> slavon@bigtelecom.ru wrote:
>> Good night! =)
>>
>> Sorry... i was wrong...
>> I see that problem more serious....
>>
>> Lets see to scheme
>>
>> Class 1
>> ---qdisc
>> ------- 10k classes
>> Class 2
>> ---qdisc
>> ------- 10k classes
>>
>> All traffic go to class 2... class 1 qdisc not have packets and if we 
>> delete it - packets not lost... in theory... lets try delete class 1 
>> qdisc (all childrens delete too)...
>> PC freeze on 2-5 seconds... its not forward any traffic at this 
>> moment... its great tree lock?
>>
>> Its normal or code need to more accurate lock?
> 
> 
> htb class destruction can be quite expansive if one of the rb trees
> needs to be rebalanced. Doing that for 10000 classes would explain
> the delay.

I've just looked at this and it seems there should be no rbtrees operations
during htb qdisc deletion (or I miss something).

Slavon, I see nearby that you teach oprofile...

Regards,
Jarek P.
