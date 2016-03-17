From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] iwlwifi: dvm: convert create_singlethread_workqueue() to
 alloc_workqueue()
Date: Thu, 17 Mar 2016 06:21:10 -0700
Message-ID: <20160317132110.GP21104@mtj.duckdns.org>
References: <1458218246-18807-1-git-send-email-eraretuya@gmail.com>
 <1458218602.2158.17.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eva Rachel Retuya <eraretuya-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	outreachy-kernel-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1458218602.2158.17.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Mar 17, 2016 at 01:43:22PM +0100, Johannes Berg wrote:
> On Thu, 2016-03-17 at 20:37 +0800, Eva Rachel Retuya wrote:
> > Use alloc_workqueue() to allocate the workqueue instead of
> > create_singlethread_workqueue() since the latter is deprecated and =
is
> > scheduled for removal.
>=20
> Scheduled where?

They've been deprecated for years now.  I should note that in the
header.

> > =A0static void iwl_setup_deferred_work(struct iwl_priv *priv)
> > =A0{
> > -	priv->workqueue =3D create_singlethread_workqueue(DRV_NAME);
> > +	priv->workqueue =3D alloc_workqueue(DRV_NAME, WQ_HIGHPRI |
> > WQ_UNBOUND |
> > +					=A0=A0WQ_MEM_RECLAIM, 1);
>=20
> Seems like you should use=A0alloc_ordered_workqueue() though? That al=
so
> gets you UNBOUND immediately, and the "1".

Right, this one should have been alloc_ordered_workqueue().

> I'm not really sure HIGHPRI is needed either.

So, no WQ_MEM_RECLAIM either then, I suppose?  What are the latency
requirements here - what happens if a thermal management work gets
delayed?

Thanks.

--=20
tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
