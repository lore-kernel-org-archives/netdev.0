From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qed: fix uninitialized data in aRFS intrastructure
Date: Thu, 11 May 2017 14:03:22 +0000
Message-ID: <BLUPR0701MB2004E8FA50C46973E09FBA298DED0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170511121633.3591880-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170511121633.3591880-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> register, which went subtly wrong due to the wrong size in a memset():
>=20
> ethernet/qlogic/qed/qed_init_fw_funcs.c: In function
> 'qed_set_rfs_mode_disable':
> ethernet/qlogic/qed/qed_init_fw_funcs.c:993:3: error: '*((void
> *)&ramline+4)' is used uninitialized in this function [-Werror=3Duninitia=
lized]
>=20
> This removes the silly loop and memset, and instead directly writes the
> correct value to the register.

Hi Arnd,

For the most part - I'm almost all in favor of this change.
But just to make it clear - the actual fix could have been a one-liner, rig=
ht?
The rest are style changes.

> +#define CAM_REG(pf_id) (PRS_REG_GFT_CAM + CAM_LINE_SIZE * (pf_id))
> +#define RAM_REG(pf_id) (PRS_REG_GFT_PROFILE_MASK_RAM +

Not sure I'm a huge fan of this specific style change;
Seems like we could easily manage without these macros.
