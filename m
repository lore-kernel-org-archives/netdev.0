From: kuznet@ms2.inr.ac.ru
Subject: Re: off by one error in 3des cbc keying
Date: Tue, 12 Nov 2002 00:35:38 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211112135.AAA28650@sex.inr.ac.ru>
References: <20021111200321.GA30957@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20021111200321.GA30957@outpost.ds9a.nl> from "bert hubert" at Nov 11, 2 09:03:21 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Communications work, then *something* expires after 30 seconds,

It is harmless, it is original request expired. However, this implies a bug,
original request must be replaced while installing negotiated SA.

It would be good if you made setkey -D before the entry expired
and started "setkey -x >& pfkey.log &" to collect pfkey traffic.



> After a few minutes, lifetime is 10 minutes:
> 20:49:07: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
> ESP/Transport 10.0.0.11->10.0.0.216 spi=137313584(0x82f3d30)

That's soft expire notification, now keys should be updated now...


> 20:49:07: ERROR: pfkey.c:206:pfkey_handler(): pfkey ADD failed:
> File exists

Wow! I see. This is an explanation. racoon uses ADD instead of UPDATE...
It should not. Oh, well, but Maxim confirmed hour ago that it works.
This is puzzle. :-) OK, I have to dig in racoon to understand what
the hell it expects.

If you prepare "setkey -x >& pfkey.log &" it will make the things
much easier to track. Please, remember, at the moment I do not have
capabilities to make any experiments here. Probably, this is for good
(stimulates imagination :-)), but I really need to have full information
to debug and not to imagine too far. :-)


> 20:51:07: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
> ESP/Transport 10.0.0.216->10.0.0.11 spi=98734594(0x5e29202)

And this is hard expire. The further is mess, apparently because
racoon is out of sync with kernel.


> And the following apparently bogus ones:

No, these are racoon's own ones. Do not worry about them. They are not used
for any packets but racoon's ones.

Alexey
