From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [IPV4] Fix secondary IP addresses after promotion
Date: Tue, 08 Nov 2005 15:11:15 +0100
Message-ID: <4370B203.8070501@trash.net>
References: <20051104184633.GA16256@skull.piratehaven.org> <436BFE08.6030906@trash.net> <20051105010740.GR23537@postel.suug.ch> <436C090D.5020201@trash.net> <436C34F8.3090903@trash.net> <20051105134636.GS23537@postel.suug.ch> <20051107215022.GH23537@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Brian Pomerantz <bapper@piratehaven.org>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965188AbVKHOMZ@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20051107215022.GH23537@postel.suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Thomas Graf <tgraf@suug.ch> 2005-11-05 14:46
> 
>>Assuming this is a separate bug, I'm not sure if this is the right
>>way to fix it. I think it would be better to rewrite the preferred
>>source address of all related local routes and only perform a
>>remove-and-add on the secondary address being promoted.
> 
> 
> I tried it out and although it works it's not clean yet because
> changing fib_info also changes pref_src for the routes to be
> deleted which will lead to slightly incorrect notifications later
> on. I now think that explicitely deleting and re-adding them
> later on is better as well ;-)

Yes, fixing it correctly looks very hard. Just changing the routes
doesn't seem right to me, someone might have added it with exactly
this prefsrc and doesn't want it to change, its also not clear how
to notify on this. Taking care of correct ordering of the ifa_list
is also more complicated without just deleting and readding them.

I have a patch to do this, but it needs some debugging, for some
unknown reason it crashes sometimes if I remove addresses without
specifying the mask.
