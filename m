From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: mark symbols static where possible
Date: Wed, 7 Sep 2016 11:55:34 +0000
Message-ID: <DM5PR11MB1723EE385BEB0EFB1AD6CC1497F80@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <1473247341-1244-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473247341-1244-1-git-send-email-baoyou.xie@linaro.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We get a few warnings when building kernel with W=3D1:
> drivers/net/ethernet/qlogic/qed/qed_l2.c:112:5: warning: no previous
> prototype for 'qed_sp_vport_start' [-Wmissing-prototypes]
> ....
>=20
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
>=20
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Most of this changes are correct. I have 2 reservations, though:

1. qed_get_vport_stats() is in use in net-next by qed_main.c starting with
6c75424612a7 ("qed: Add support for NCSI statistics."), so we shouldn't
make it static.
[This raises the question of which repository was this patch built against?=
]

2. Regarding the changes in qed_cxt.c - some of the functions you're turnin=
g
into static are going to be used be other files in our pending RoCE driver
submissions [you could say those ARE really missing their prototypes].
I don't have a real objection to this change - I'm just stating that if you=
'll
change those now to static, we'll probably 'revert' the change in the near
future.
