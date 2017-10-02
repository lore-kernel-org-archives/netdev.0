From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 05/18] net: use ARRAY_SIZE
Date: Mon, 02 Oct 2017 16:46:29 +0300
Message-ID: <87h8vh64sq.fsf@codeaurora.org>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
        <20171001193101.8898-6-jeremy.lefaure@lse.epita.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, linux-usb@vger.kerne
To: =?utf-8?B?SsOpcsOpbXk=?= Lefaure <jeremy.lefaure@lse.epita.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171001193101.8898-6-jeremy.lefaure@lse.epita.fr>
 (=?utf-8?B?IkrDqXLDqW15?=
        Lefaure"'s message of "Sun, 1 Oct 2017 15:30:43 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J=C3=A9r=C3=A9my Lefaure <jeremy.lefaure@lse.epita.fr> writes:

> Using the ARRAY_SIZE macro improves the readability of the code. Also,
> it is not always useful to use a variable to store this constant
> calculated at compile time.
>
> Found with Coccinelle with the following semantic patch:
> @r depends on (org || report)@
> type T;
> T[] E;
> position p;
> @@
> (
>  (sizeof(E)@p /sizeof(*E))
> |
>  (sizeof(E)@p /sizeof(E[...]))
> |
>  (sizeof(E)@p /sizeof(T))
> )
>
> Signed-off-by: J=C3=A9r=C3=A9my Lefaure <jeremy.lefaure@lse.epita.fr>
> ---
>  drivers/net/ethernet/emulex/benet/be_cmds.c        |   4 +-
>  drivers/net/ethernet/intel/i40e/i40e_adminq.h      |   3 +-
>  drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   3 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c      |   3 +-
>  drivers/net/ethernet/intel/ixgbevf/vf.c            |  17 +-
>  drivers/net/usb/kalmia.c                           |   9 +-
>  .../broadcom/brcm80211/brcmsmac/phy/phytbl_n.c     | 473 ++++++---------=
------
>  .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   9 +-
>  .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |  12 +-
>  .../net/wireless/realtek/rtlwifi/rtl8723be/table.c |  14 +-
>  .../net/wireless/realtek/rtlwifi/rtl8821ae/table.c |  34 +-
>  include/net/bond_3ad.h                             |   3 +-
>  net/ipv6/seg6_local.c                              |   6 +-
>  13 files changed, 177 insertions(+), 413 deletions(-)

We have a tree for wireless so usually it's better to submit wireless
changes on their own but here I assume Dave will apply this to his tree.
If not, please resubmit the wireless part in a separate patch.

--=20
Kalle Valo
