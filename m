From: Donald Becker <becker@scyld.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Fri, 3 Jan 2003 19:07:11 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301031856330.29812-100000@beohost.scyld.com>
References: <20030103164001.S48623@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030103164001.S48623@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Jan 2003, jamal wrote:

> Subject: SIOCADDMULTI for unicast broken
>
> Some programs require ability to accept packets destined to certain
> MAC addresses (in addition to their own).
> Example Jerome Ettienes vrrpd (http://w3.arobas.net/~jetienne/vrrpd/)
> 
> The trick is to add unicast addresses via SIOCADDMULTI and accept those
> packets when they make their way up the stack.
> I think this used to work, no? Donald, any history/comments behind
> this?

This is a very specialized requirement, so specialized that it should
not be added as general-purpose requirement for drivers or the network
stack.

This capability was supported as a special case for the Tulip driver,
and then only for the real 21*4* chips that had the hardware CAM capable
of matching up to 16 destination addresses.

A few other chips support matching unicast addresses with the multicast
filter, but there is the general problem of false-accepts and
chip-specific quirks that must be dealt with.

Once again: this is a very specialized thing.  Of the few people that
think they need the capability, most are wrong.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
