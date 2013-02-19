From: Borislav Petkov <bp@alien8.de>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 12:43:46 +0100
Message-ID: <20130219114345.GA26623@pd.tnic>
References: <20130218164638.7cb53baa@redhat.com>
 <20130218200542.GB20137@arwen.pp.htv.fi>
 <20130218184742.5a4c3c06@redhat.com>
 <20130218215434.GB16794@kroah.com>
 <20130218221306.GA21493@pd.tnic>
 <20130218222618.GA21818@kroah.com>
 <20130218224405.GB21493@pd.tnic>
 <20130219070310.2cadad7a@redhat.com>
 <20130219101121.GJ23197@arwen.pp.htv.fi>
 <20130219081149.46972f56@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: balbi@ti.com, Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Mauro Carvalho Chehab <mchehab@redhat.com>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130219081149.46972f56@redhat.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 19, 2013 at 08:11:49AM -0300, Mauro Carvalho Chehab wrote:
> > > I remember I saw some discussions about it in the past at bluesmo=
ke ML,
> > > saying that -ENODEV is the expected behavior when this is not sup=
ported.
> > >=20
> > > Changing from -ENODEV to "N/A" will break anything that would be =
relying
> > > on the previous behavior. So, I think that such change will for s=
ure break
> > > userspace.
> > >=20
> > > If we're willing to change it, not creating the "sdram_scrub_rate=
" sysfs=20
> > > node is less likely to affect userspace.

This will break scripts which assume this file's presence implicitly.

[ =E2=80=A6 ]

> @@ -1017,6 +1010,14 @@ int edac_create_sysfs_mci_device(struct mem_ct=
l_info *mci)
>  		return err;
>  	}
> =20
> +	if (mci->set_sdram_scrub_rate && mci->get_sdram_scrub_rate) {

This will break cpc925_edac.c because it defines a
->get_sdram_scrub_rate but not a ->set_sdram_scrub_rate.

I think a maybe better fix would be to figure out the sysfs file
permissions based on the presence of the two functions and *then* add
the attribute.

This way, the only visible change to userspace is the corrected sysfs
file permissions.

--=20
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
