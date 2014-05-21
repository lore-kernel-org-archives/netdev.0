From: Rajkumar Manoharan <rmanohar@qti.qualcomm.com>
Subject: Re: [ath9k-devel] randconfig build error with next-20140519, in
 drivers/net/wireless/ath/ath9k/dfs.c
Date: Wed, 21 May 2014 20:08:34 +0530
Message-ID: <20140521143832.GA9563@qca.qualcomm.com>
References: <CA+r1ZhiM7EK08Y4kriXMugMc1Mbj5VDUPwKMq8-_k8Q8qhwPtw@mail.gmail.com>
 <20140521110143.GA2375@qca.qualcomm.com>
 <CAGRGNgXuS-ksFBAtmo8nLAPqPFKo2gHGDCsTcranU-k2-K3rfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linville <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	<ath9k-devel@lists.ath9k.org>, netdev <netdev@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGRGNgXuS-ksFBAtmo8nLAPqPFKo2gHGDCsTcranU-k2-K3rfg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2014 at 10:12:26PM +1000, Julian Calaby wrote:
> Hi Rajkumar,
>=20
> On Wed, May 21, 2014 at 9:01 PM, Rajkumar Manoharan
> <rmanohar@qti.qualcomm.com> wrote:
> > On Mon, May 19, 2014 at 09:31:16AM -0700, Jim Davis wrote:
> >> Building with the attached random configuration file,
> >>
> >> In file included from drivers/net/wireless/ath/ath9k/eeprom.h:22:0=
,
> >>                  from drivers/net/wireless/ath/ath9k/hw.h:27,
> >>                  from drivers/net/wireless/ath/ath9k/dfs.c:18:
> >> drivers/net/wireless/ath/ath9k/dfs.c: In function =E2=80=98ath9k_d=
fs_process_phyerr=E2=80=99:
> >> drivers/net/wireless/ath/ath9k/dfs.c:185:14: error: =E2=80=98struc=
t ath_softc=E2=80=99
> >> has no member named =E2=80=98debug=E2=80=99
> >>     pe.ts - sc->debug.stats.dfs_stats.last_ts);
> >>               ^
> >> drivers/net/wireless/ath/ath9k/../ath.h:273:41: note: in definitio=
n of
> >> macro =E2=80=98ath_dbg=E2=80=99
> >>    ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__); \
> >>                                          ^
> >> drivers/net/wireless/ath/ath9k/dfs.c:186:5: error: =E2=80=98struct=
 ath_softc=E2=80=99
> >> has no member named =E2=80=98debug=E2=80=99
> >>    sc->debug.stats.dfs_stats.last_ts =3D pe.ts;
> >>      ^
> >> make[5]: *** [drivers/net/wireless/ath/ath9k/dfs.o] Error 1
> >
> > Please select CONFIG_ATH9K_DEBUGFS.
>=20
> The point of randconfig builds is to ensure that there it's really
> unlikely that there are any config combinations that don't build, eve=
n
> if they're utterly insane.
>=20
> You should really change the ath9k Kconfig rules or move or add ifdef=
s
> to prevent this from being possible.
>
Completely agree. But ath9k Kconfig has proper dependecy for
ATH9K_DFS_DEBUGFS. I am wondering how it is selected w/o ATH9K_DEBUGFS.

config ATH9K_DFS_DEBUGFS
        def_bool y
	depends on ATH9K_DEBUGFS && ATH9K_DFS_CERTIFIED

Should it be like this?

config ATH9K_DFS_DEBUGFS
	def_bool y if (ATH9K_DEBUGFS && ATH9K_DFS_CERTIFIED)

-Rajkumar
