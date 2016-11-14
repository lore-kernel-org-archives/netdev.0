From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH net-next v7 03/10] dpaa_eth: add option to use one buffer
 pool set
Date: Mon, 14 Nov 2016 10:25:13 +0000
Message-ID: <AM4PR04MB16040D32960405FD16007950ECBC0@AM4PR04MB1604.eurprd04.prod.outlook.com>
References: <1478852407-27420-1-git-send-email-madalin.bucur@nxp.com>
 <1478852407-27420-4-git-send-email-madalin.bucur@nxp.com>
 <20161113.124617.2176429700446266337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "ppc@mindchasers.com" <ppc@mindchasers.com>,
 "oss@buserror.net" <oss@buserror.net>, "joe@perches.com" <joe@perches.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20161113.124617.2176429700446266337.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, November 13, 2016 7:46 PM
>=20
> From: Madalin Bucur <madalin.bucur@nxp.com>
> Date: Fri, 11 Nov 2016 10:20:00 +0200
>=20
> > @@ -8,3 +8,12 @@ menuconfig FSL_DPAA_ETH
> >  	  supporting the Freescale QorIQ chips.
> >  	  Depends on Freescale Buffer Manager and Queue Manager
> >  	  driver and Frame Manager Driver.
> > +
> > +if FSL_DPAA_ETH
> > +config FSL_DPAA_ETH_COMMON_BPOOL
> > +	bool "Use a common buffer pool set for all the interfaces"
> > +	---help---
> > +	  The DPAA Ethernet netdevices require buffer pools for storing the
> buffers
> > +	  used by the FMan hardware for reception. One can use a single
> buffer pool
> > +	  set for all interfaces or a dedicated buffer pool set for each
> interface.
> > +endif # FSL_DPAA_ETH
>=20
> This in no way belongs in Kconfig.  If you want to support this,
> support it wit a run time configuration choice via ethtool flags
> or similar.  Do not use debugfs, do not use sysfs, do not use
> module options.
>=20
> If you put it in Kconfig, distributions will have to pick one way or
> another which means that users who want the other choice lose.  This
> never works.

I've introduced this Kconfig option as a backwards compatible option, to
be able to run comparative tests between the independent buffer pool setup
and the previous common buffer pool setup. There are not so many reasons
to use the same buffer pool besides "having the old setup", the memory
saving is marginal, in all other aspects the separate buffer pools setup
fares better.

I'll remove this patch from the next submission. Should anyone care for
this I can add an entry to the feature backlog to add runtime support but
it will be quite low in priority.

Thank you for your review.=20

Madalin
