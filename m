From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: make packet_type->ak_packet_priv generic
Date: Fri, 4 Apr 2014 16:47:17 +0200
Message-ID: <20140404144717.GC2892@minipsycho.brq.redhat.com>
References: <1396614038-31975-1-git-send-email-jiri@resnulli.us>
 <20140404.095420.1460518706334112992.davem@davemloft.net>
 <20140404140325.GB2892@minipsycho.brq.redhat.com>
 <20140404.100754.1337061118939924472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com, vfalico@redhat.com,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hkchu@google.com, dborkman@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, atzm@stratosphere.co.jp, phil@nwl.cc,
	richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:63020 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbaDDOrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 10:47:21 -0400
Received: by mail-we0-f169.google.com with SMTP id w62so3605246wes.0
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 07:47:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140404.100754.1337061118939924472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 04, 2014 at 04:07:54PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 4 Apr 2014 16:03:25 +0200
>
>> Fri, Apr 04, 2014 at 03:54:20PM CEST, davem@davemloft.net wrote:
>>>From: Jiri Pirko <jiri@resnulli.us>
>>>Date: Fri,  4 Apr 2014 14:20:38 +0200
>>>
>>>> The priv is used now by af_packet. Rename it to make it useable for
>>>> others as well. Also, introduce packet_id_match to move the sk matching
>>>> from skb_loop_sk to af_packet code where it belongs.
>>>> 
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>
>>>Firstly, net-next is closed.
>> 
>> Dave, it would be really great if you stick with the same email subject
>> when you declare net-next closed. I was looking for "CLOSED" but now the
>> subject is "no new feature patches please" which I missed.
>
>Sorry, that's not a reasonable request.
>
>It is very clear from the subject line I choose what the message is
>about.  I don't have to use an ALL CAPS subject line "just because"

That was just an example. You used that already, for example:
Date: Tue, 19 Feb 2013 00:56:53 -0500 (EST)
From: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Subject: net-next is CLOSED

Please don't get me wrong, I'm just making a suggestion. As Nicolas wrote,
it would save your time. And others as well when they know what to 'grep'.


>
>>>Secondly, submit this with the unmentioned and mysterious "other
>>>user", there currently are none.
>> 
>> There is none atm. But anyway, the struct field name should be generic,
>> cause this is not specific to af_packet. Anybody might want to pass a
>> "priv".
>
>No, because it makes it clear what the one and only user is.

Well there are others which would use this priv as well. For example:
drivers/scsi/bnx2fc/bnx2fc_fcoe.c

They work around this by embedding struct packet_type into their priv and in
_rcv they access it by container_of.

At the end I think it would be nicer to allow struct packet_type to be
defined static by users and pass priv and dev as parameters to dev_add_pack()

>
>Any new user would be seriously frowned upon, because this is
>an easy side channel for proprietary extensions to the networking.
