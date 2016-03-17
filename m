From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: [PATCH] iwlwifi: dvm: convert create_singlethread_workqueue()
 to alloc_workqueue()
Date: Thu, 17 Mar 2016 13:48:36 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32EA7CBB1@hasmsx107.ger.corp.intel.com>
References: <1458218246-18807-1-git-send-email-eraretuya@gmail.com>
 <1458218602.2158.17.camel@sipsolutions.net>
 <20160317132110.GP21104@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1255
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eva Rachel Retuya <eraretuya@gmail.com>,
	"outreachy-kernel@googlegroups.com"
	<outreachy-kernel@googlegroups.com>,
	linuxwifi <linuxwifi@intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160317132110.GP21104@mtj.duckdns.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hello,
>=20
> On Thu, Mar 17, 2016 at 01:43:22PM +0100, Johannes Berg wrote:
> > On Thu, 2016-03-17 at 20:37 +0800, Eva Rachel Retuya wrote:
> > > Use alloc_workqueue() to allocate the workqueue instead of
> > > create_singlethread_workqueue() since the latter is deprecated an=
d
> > > is scheduled for removal.
> >
> > Scheduled where?
>=20
> They've been deprecated for years now.  I should note that in the hea=
der.
>=20
> > > =A0static void iwl_setup_deferred_work(struct iwl_priv *priv)
> > > =A0{
> > > -	priv->workqueue =3D create_singlethread_workqueue(DRV_NAME);
> > > +	priv->workqueue =3D alloc_workqueue(DRV_NAME, WQ_HIGHPRI |
> > > WQ_UNBOUND |
> > > +					=A0=A0WQ_MEM_RECLAIM, 1);
> >
> > Seems like you should use=A0alloc_ordered_workqueue() though? That =
also
> > gets you UNBOUND immediately, and the "1".
>=20
> Right, this one should have been alloc_ordered_workqueue().
>=20
> > I'm not really sure HIGHPRI is needed either.
>=20
> So, no WQ_MEM_RECLAIM either then, I suppose?  What are the latency
> requirements here - what happens if a thermal management work gets
> delayed?
>=20

This worker is not supposed to free memory, so no WQ_MEM_RECLAIM needed=
=2E The latency is not critical.
