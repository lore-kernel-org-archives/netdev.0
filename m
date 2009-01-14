From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [PATCH 08/16] dma-debug: add core checking functions
Date: Wed, 14 Jan 2009 12:44:01 +0100
Message-ID: <20090114114401.GL20283@amd.com>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-9-git-send-email-joerg.roedel@amd.com> <20090110231127.GK17917@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761409AbZANLog@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090110231127.GK17917@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 11, 2009 at 12:11:27AM +0100, Ingo Molnar wrote:
>=20
> * Joerg Roedel <joerg.roedel@amd.com> wrote:
>=20
> > +#define err_printk(dev, format, arg...) do {			\
> > +		error_count +=3D 1;				\
> > +		if (show_all_errors || show_num_errors > 0) {	\
> > +			WARN(1, "%s %s: " format,		\
> > +			     dev_driver_string(dev),		\
> > +			     dev_name(dev) , ## arg);		\
> > +		}						\
> > +		if (!show_all_errors && show_num_errors > 0)	\
> > +			show_num_errors -=3D 1;			\
>=20
> Note that the arithmetics here is SMP-unsafe: we only hold the hash b=
ucket=20
> so if two errors hit at once on two CPUs then the error tracking vari=
ables=20
> can be accessed at once.
>=20
> I'd suggest a simple global lock for this error case (taken inside th=
e=20
> hash bucket lock), to be on the safe side.

As I wrote in a previous email, a race here is no big deal. I add a
comment to document it. Or do we want another global lock here?

> Also, please dont use a macro for this - printk details can be passed=
 in=20
> to helper inlines/functions too.

Hmm, how does this look like? There is not WARN variant which can use
va_args as a parameter. And it is important that the error message is
logged in the warning itself. So the driver developer can see it when a
user reports the warning.

Joerg

--=20
           | Advanced Micro Devices GmbH
 Operating | Karl-Hammerschmidt-Str. 34, 85609 Dornach bei M=C3=BCnchen
 System    |=20
 Research  | Gesch=C3=A4ftsf=C3=BChrer: Jochen Polster, Thomas M. McCoy=
, Giuliano Meroni
 Center    | Sitz: Dornach, Gemeinde Aschheim, Landkreis M=C3=BCnchen
           | Registergericht M=C3=BCnchen, HRB Nr. 43632
