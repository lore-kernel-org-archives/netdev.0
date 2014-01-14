From: Martin Kaiser <martin@kaiser.cx>
Subject: Re: [PATCH -next] qlcnic: fix compiler warning
Date: Tue, 14 Jan 2014 16:21:28 +0100
Message-ID: <20140114152127.GA13575@reykholt.kaiser.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shahed.shaikh@qlogic.com,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

re-sent as requested by David M.
(I understand the concerns about portability that were raised. At the m=
oment, I don't have a possiblity to do
further rework and testing)

Add an explicit cast to fix the following warning
(seen on Debian Wheezy, gcc 4.7.2)

CC [M]  drivers/net/wireless/rtlwifi/rtl8192ce/trx.o
    drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c: In function =E2=80=98=
qlcnic_send_filter=E2=80=99:
    drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:349:3: warning:     =
             =20
    passing argument 2 of =E2=80=98ether_addr_equal=E2=80=99 from incom=
patible pointer type [enabled by default]
    In file included from include/linux/if_vlan.h:16:0,                =
                        =20
    from drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:9:
    include/linux/etherdevice.h:244:20: note: expected =E2=80=98const u=
8 *=E2=80=99 but argument is of type =E2=80=98u64 *=E2=80=99

Signed-off-by: Martin Kaiser <martin@kaiser.cx>
Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/n=
et/ethernet/qlogic/qlcnic/qlcnic_io.c
index 6373f60..3557154 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -346,7 +346,7 @@ static void qlcnic_send_filter(struct qlcnic_adapte=
r *adapter,
        head =3D &(adapter->fhash.fhead[hindex]);

        hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
-               if (ether_addr_equal(tmp_fil->faddr, &src_addr) &&
+               if (ether_addr_equal(tmp_fil->faddr, (const u8 *)&src_a=
ddr) &&
                    tmp_fil->vlan_id =3D=3D vlan_id) {
                        if (jiffies > (QLCNIC_READD_AGE * HZ + tmp_fil-=
>ftime))
                                qlcnic_change_filter(adapter, &src_addr=
,
