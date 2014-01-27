From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 1/3] qeth: bridgeport support - basic control
Date: Mon, 27 Jan 2014 07:49:04 +0100
Message-ID: <20140127064904.GA34645@tuxmaker.boeblingen.de.ibm.com>
References: <20140114145410.453840919@de.ibm.com> <20140114145509.287096531@de.ibm.com> <CAP=VYLp385bCpGiyDma82sO2zJkzArqUrHXYf0Bft6-WNj92Lg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:48313 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbaA0GtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 01:49:09 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Mon, 27 Jan 2014 06:49:07 -0000
Content-Disposition: inline
In-Reply-To: <CAP=VYLp385bCpGiyDma82sO2zJkzArqUrHXYf0Bft6-WNj92Lg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 24, 2014 at 04:23:01PM -0500, Paul Gortmaker wrote:
> On Tue, Jan 14, 2014 at 9:54 AM,  <frank.blaschka@de.ibm.com> wrote:
> > From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
> >
> > Introduce functions to assign roles and check state of bridgeport-capable
> > HiperSocket devices, and sysfs attributes providing access to these
> > functions from userspace. Introduce udev events emitted when the state
> > of a bridgeport device changes.
> >
> > Signed-off-by: Eugene Crosser <eugene.crosser@ru.ibm.com>
> > Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> > Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
> 
> Hi Eugene,
> 
> This commit breaks the linux-next builds of s390 allmodconfig:
> 
> Bisecting: 0 revisions left to test after this (roughly 0 steps)
> [b4d72c08b358fc5b259fad0f4971112d949efd1c] qeth: bridgeport support -
> basic control
> running ./x
> scripts/kconfig/conf --allmodconfig Kconfig
> #
> # configuration written to .config
> #
> ERROR: "qeth_wq" [drivers/s390/net/qeth_l2.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> b4d72c08b358fc5b259fad0f4971112d949efd1c is the first bad commit
> commit b4d72c08b358fc5b259fad0f4971112d949efd1c
> Author: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
> Date:   Tue Jan 14 15:54:11 2014 +0100
> 
>     qeth: bridgeport support - basic control
> 
>     Introduce functions to assign roles and check state of bridgeport-capable
>     HiperSocket devices, and sysfs attributes providing access to these
>     functions from userspace. Introduce udev events emitted when the state
>     of a bridgeport device changes.
> 
>     Signed-off-by: Eugene Crosser <eugene.crosser@ru.ibm.com>
>     Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
>     Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> :040000 040000 1eb4205806a03dbc3de37af46e9447168b0d0e2a
> 0ba638a94d92c41d732bedc54c8108775f689cf3 M      Documentation
> :040000 040000 9a9eb7da725785bfe40c77cdee4c181c90f74ef3
> f7e69854a168599f2f191675b449783292b0a4a1 M      drivers
> bisect run success
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/10509367/
> 
> Paul.
> --
>
Paul, thx for this information. We are working on a fix. Hope I can sent it out
later this day.
 
> > ---
> >  Documentation/s390/qeth.txt       |  21 +++
> >  drivers/s390/net/Makefile         |   2 +-
> >  drivers/s390/net/qeth_core.h      |  25 +++
> >  drivers/s390/net/qeth_core_main.c |  14 +-
> >  drivers/s390/net/qeth_core_mpc.c  |   1 +
> >  drivers/s390/net/qeth_core_mpc.h  |  84 +++++++++
> >  drivers/s390/net/qeth_l2.h        |  15 ++
> >  drivers/s390/net/qeth_l2_main.c   | 364 ++++++++++++++++++++++++++++++++++++++
> >  drivers/s390/net/qeth_l2_sys.c    | 161 +++++++++++++++++
> >  9 files changed, 685 insertions(+), 2 deletions(-)
> >  create mode 100644 Documentation/s390/qeth.txt
> >  create mode 100644 drivers/s390/net/qeth_l2.h
> >  create mode 100644 drivers/s390/net/qeth_l2_sys.c
> >
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
