From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net-next V3 13/23] ptp: igb: convert to the 64 bit
 get/set time methods.
Date: Thu, 2 Apr 2015 00:06:56 +0000
Message-ID: <02874ECE860811409154E81DA85FBB58574FB888@ORSMSX115.amr.corp.intel.com>
References: <cover.1427662906.git.richardcochran@gmail.com>
 <67fa71b28f96b222c8027b49efee4144b3754bf7.1427662907.git.richardcochran@gmail.com>
 <20150331215317.GA9339@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Luwei Zhou" <b45643@freescale.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
To: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150331215317.GA9339@localhost.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Tuesday, March 31, 2015 2:53 PM
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org; Amir Vadai; Ariel Elior; Arnd Bergm=
ann;
> Baolin Wang; Ben Hutchings; Allan, Bruce W; Wyborny, Carolyn; Chris
> Metcalf; David Miller; Frank Li; Giuseppe Cavallaro; Keller, Jacob E;=
 Kirsher,
> Jeffrey T; John Stultz; Luwei Zhou; Vick, Matthew; Michael Chan; Pras=
hant
> Sreedharan; Rayagond K; Shradha Shah; Solarflare linux maintainers; S=
onic
> Zhang; Stefan S=F8rensen; Thomas Gleixner; Tom Lendacky
> Subject: Re: [PATCH net-next V3 13/23] ptp: igb: convert to the 64 bi=
t
> get/set time methods.
>=20
> On Sun, Mar 29, 2015 at 11:12:03PM +0200, Richard Cochran wrote:
>=20
> > @@ -627,11 +628,11 @@ static void igb_ptp_overflow_check(struct
> work_struct *work)
> >  {
> >  	struct igb_adapter *igb =3D
> >  		container_of(work, struct igb_adapter,
> ptp_overflow_work.work);
> > -	struct timespec ts;
> > +	struct timespec64 ts;
> >
> > -	igb->ptp_caps.gettime(&igb->ptp_caps, &ts);
> > +	igb->ptp_caps.gettime64(&igb->ptp_caps, &ts);
> >
> > -	pr_debug("igb overflow check at %ld.%09lu\n", ts.tv_sec,
> ts.tv_nsec);
> > +	pr_debug("igb overflow check at %lld.%09lu\n", ts.tv_sec,
> ts.tv_nsec);
>=20
> For a 64 bit build, this produces the same warning as e1000e.
>=20
> What is the best way to deal with this warning?
>=20
> Thanks,
> Richard

I don't know how kernel would fix this. Usually macros like PRI64d are =
used but I am not sure those are defined for the kernel builds

Regards,
Jake
