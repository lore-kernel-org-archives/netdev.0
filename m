From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Fri, 20 Nov 2015 07:55:44 +0900
Message-ID: <CAKD1Yr2mCs_v2posCVz=YwhCPvGVH+=VCBpWWf2TB-2aDj5R+w@mail.gmail.com>
References: <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
 <20151119.104811.1447518072450380661.davem@davemloft.net> <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151119.113336.1788979303067913870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:33376 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbbKSW4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 17:56:05 -0500
Received: by ykdv3 with SMTP id v3so133197785ykd.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 14:56:04 -0800 (PST)
In-Reply-To: <20151119.113336.1788979303067913870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 1:33 AM, David Miller <davem@davemloft.net> wrote:
>> Every-time I make a change in linux TCP stack, this code breaks, and
>> this a  real pain because Android changes need to be carried over to
>> vendors.
>
> I'm very glad that you felt the pain enough that you finally had
> to reluctantly try and upstream something.  I'm sorry that doing
> hackish things locally in the Android kernel tree is so painful :-/

Actually, when SIOCKILLADDR crashes users' phones, Eric is not the one
that needs to fix this. I am. Because I am not a TCP expert or a
hardcode kernel developer, I ask Eric for help, and he is good enough
to provide it.

> Android folks really do not care about upstream, and it is probably
> bottom of their priority.  Their actions consistently support this.

Speaking as the one of the Android networking team leads, I would love
it if that changed. It would certainly make my life easier if these
features were upstream. I am trying to upstream all of them so that I
don't have to worry about ensuring that all devices pick them up as
opposed to shipping kernels that lack important commits, and thus
contain subtle bugs that cause real networking problems for real
users.

Pretty much everything we have done in networking code in the past two
years we have tried to upstream - see patches by myself and Erik Kline
that got merged. Some of the things we do are ugly hacks that we've
were expedient at the time, like SIOCKILLADDR. Eric rightly says it's
evil and racy. For those, we try to come up with something that's a
better solution, and we send it upstream. This is one of the results.
