From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next 6/9] mlxsw: spectrum: Unmap local port from
 module during teardown
Date: Mon, 22 Feb 2016 23:50:34 -0500
Message-ID: <20160223045033.GO33942@gospo.home.greyhouse.net>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <1456165924-14399-7-git-send-email-jiri@resnulli.us>
 <56CB706F.3000301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, jeffrey.t.kirsher@intel.com,
	brouer@redhat.com, ivecera@redhat.com, rami.rosen@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:36155 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178AbcBWEui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 23:50:38 -0500
Received: by mail-yk0-f179.google.com with SMTP id z7so71230239yka.3
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 20:50:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56CB706F.3000301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2016 at 12:32:47PM -0800, John Fastabend wrote:
> On 16-02-22 10:32 AM, Jiri Pirko wrote:
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > When splitting a port we replace it with 2 or 4 other ports. To be able
> > to do that we need to remove the original port netdev and unmap it from
> > its module. However, we first mark it as disabled, as active ports
> > cannot be unmapped.
> > 
> > Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > ---
> 
> Hi Jiri, Ido,
> 
> You've sort of lost me on this port splitting/unsplitting thread. What
> does this actually do? Are you just creating two netdevs and LAGing them
> in the hardware, I'm guessing not or you wouldn't have some device API
> for it and would do it using normal methods.
> 
> If its something to do with physical layout of the board itself why
> don't you trigger this based on some init time introspection or an
> interrupt if someone plugs in a port splitting cable/module (does that
> exist?).

In some implementations there are interrupts that fire when modules are
connected or removed.  Even if an interrupt doesn't fire, it would be
possible to have a timer event/workqueue in a driver that could read
QFSP VPD information periodically to note that something has changed in
the hardware and reconfigure as needed.  I actually would perfer keying
on something like that to perform a configuration change like rather
than requiring the user configure it.

Today you have to swap a 4x10GbE for a 1x40GbE module and then
performing significant software config (possibly flashing EEPROMs in the
case of some NICs) each time.  That seems too error prone as a user
could swap out a QSFP on what they think is one port on a switch and
then perform a software change on another port without realizing it.

That accidental disruption seems less tolerable than the one where there
wrong physical port was added and removed and config needs to be
applied.  Network management apps can properly solve the problem where
devices come and go accidently due to connecting the wrong QSFP, so that
seems like a less critical use-case to handle than what I described
above.
