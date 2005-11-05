From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [IPV4] Fix secondary IP addresses after promotion
Date: Sat, 05 Nov 2005 05:28:40 +0100
Message-ID: <436C34F8.3090903@trash.net>
References: <20051104184633.GA16256@skull.piratehaven.org> <436BFE08.6030906@trash.net> <20051105010740.GR23537@postel.suug.ch> <436C090D.5020201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brian Pomerantz <bapper@piratehaven.org>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751382AbVKEHqD@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <436C090D.5020201@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Thomas Graf wrote:
> 
>> broadcast 10.0.0.0  proto kernel  scope link  src 10.0.0.2 local 
>> 10.0.0.2  proto kernel  scope host  src 10.0.0.2 broadcast 10.0.0.255  
>> proto kernel  scope link  src 10.0.0.2
>> Local routes for 10.0.0.3 and 10.0.0.4 have disappeared _without_
>> any notification.
>>
>> I think the correct way to fix this is to prevent the deletion of
>> the local routes, not just readding them. _If_ the deletion of them
>> is intended, which I doubt, then at least notifications must be
>> sent out.
> 
> I agree, the routes should ideally not be deleted at all. The missing
> notifications appear to be a different bug. Let me have another look ..

The reason why all routes are deleted is because their prefered
source addresses is the primary address. fn_flush_list should
probably send the missing notifications for the deleted routes.
Changing address promotion to not delete the other routes at all
looks extremly complicated, I think just fixing it to behave
correctly is good enough (which my patch didn't do entirely,
I'll send a new one this weekend).
