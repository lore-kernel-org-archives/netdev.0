From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [IPV4] Fix secondary IP addresses after promotion
Date: Sat, 5 Nov 2005 14:46:36 +0100
Message-ID: <20051105134636.GS23537@postel.suug.ch>
References: <20051104184633.GA16256@skull.piratehaven.org> <436BFE08.6030906@trash.net> <20051105010740.GR23537@postel.suug.ch> <436C090D.5020201@trash.net> <436C34F8.3090903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Pomerantz <bapper@piratehaven.org>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751153AbVKENqR@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <436C34F8.3090903@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2005-11-05 05:28
> The reason why all routes are deleted is because their prefered
> source addresses is the primary address. fn_flush_list should
> probably send the missing notifications for the deleted routes.
> Changing address promotion to not delete the other routes at all
> looks extremly complicated, I think just fixing it to behave
> correctly is good enough (which my patch didn't do entirely,
> I'll send a new one this weekend).

Yes, fib_sync_down(), but even when I remove the code setting
RTNH_F_DEAD I still see _some_ local routes disappearing which
I cannot explain right now. I can only reproduce this with
!CONFIG_IP_MULTIPLE_TABLES though.

Assuming this is a separate bug, I'm not sure if this is the right
way to fix it. I think it would be better to rewrite the preferred
source address of all related local routes and only perform a
remove-and-add on the secondary address being promoted.

_If_ we let them die, we should announce it in fib_sync_down()
rather then in the algorithm specific flush routines.
