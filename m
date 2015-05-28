From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of most of the trees
Date: Thu, 28 May 2015 22:06:07 +1000
Message-ID: <20150528220607.67a68696@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/jr3v6dE4Xbwj_A_97xYdPCC"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/jr3v6dE4Xbwj_A_97xYdPCC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the all the trees, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/vhost/scsi.c: In function 'vhost_scsi_open':
drivers/vhost/scsi.c:1422:3: error: implicit declaration of function 'vzall=
oc' [-Werror=3Dimplicit-function-declaration]
   vs =3D vzalloc(sizeof(*vs));
   ^
drivers/vhost/scsi.c:1422:6: warning: assignment makes pointer from integer=
 without a cast
   vs =3D vzalloc(sizeof(*vs));
      ^
drivers/target/target_core_pr.c: In function 'core_scsi3_update_and_write_a=
ptpl':
drivers/target/target_core_pr.c:1985:2: error: implicit declaration of func=
tion 'vzalloc' [-Werror=3Dimplicit-function-declaration]
  buf =3D vzalloc(len);
  ^
drivers/target/target_core_pr.c:1985:6: warning: assignment makes pointer f=
rom integer without a cast
  buf =3D vzalloc(len);
      ^
drivers/target/target_core_pr.c:1991:3: error: implicit declaration of func=
tion 'vfree' [-Werror=3Dimplicit-function-declaration]
   vfree(buf);
   ^
drivers/target/target_core_transport.c: In function 'transport_alloc_sessio=
n_tags':
drivers/target/target_core_transport.c:258:3: error: implicit declaration o=
f function 'vzalloc' [-Werror=3Dimplicit-function-declaration]
   se_sess->sess_cmd_map =3D vzalloc(tag_num * tag_size);
   ^
drivers/target/target_core_transport.c:258:25: warning: assignment makes po=
inter from integer without a cast
   se_sess->sess_cmd_map =3D vzalloc(tag_num * tag_size);
                         ^
drivers/target/target_core_transport.c:270:4: error: implicit declaration o=
f function 'vfree' [-Werror=3Dimplicit-function-declaration]
    vfree(se_sess->sess_cmd_map);
    ^
drivers/target/target_core_transport.c: In function 'transport_kmap_data_sg=
':
drivers/target/target_core_transport.c:2317:2: error: implicit declaration =
of function 'vmap' [-Werror=3Dimplicit-function-declaration]
  cmd->t_data_vmap =3D vmap(pages, cmd->t_data_nents,  VM_MAP, PAGE_KERNEL);
  ^
drivers/target/target_core_transport.c:2317:53: error: 'VM_MAP' undeclared =
(first use in this function)
  cmd->t_data_vmap =3D vmap(pages, cmd->t_data_nents,  VM_MAP, PAGE_KERNEL);
                                                     ^
drivers/target/target_core_transport.c: In function 'transport_kunmap_data_=
sg':
drivers/target/target_core_transport.c:2335:2: error: implicit declaration =
of function 'vunmap' [-Werror=3Dimplicit-function-declaration]
  vunmap(cmd->t_data_vmap);
  ^
drivers/target/target_core_file.c: In function 'fd_format_prot':
drivers/target/target_core_file.c:809:2: error: implicit declaration of fun=
ction 'vzalloc' [-Werror=3Dimplicit-function-declaration]
  buf =3D vzalloc(unit_size);
  ^
drivers/target/target_core_file.c:809:6: warning: assignment makes pointer =
from integer without a cast
  buf =3D vzalloc(unit_size);
      ^
drivers/target/target_core_file.c:822:2: error: implicit declaration of fun=
ction 'vfree' [-Werror=3Dimplicit-function-declaration]
  vfree(buf);
  ^
drivers/target/target_core_user.c: In function 'tcmu_configure_device':
drivers/target/target_core_user.c:895:2: error: implicit declaration of fun=
ction 'vzalloc' [-Werror=3Dimplicit-function-declaration]
  udev->mb_addr =3D vzalloc(TCMU_RING_SIZE);
  ^
drivers/target/target_core_user.c:895:16: warning: assignment makes pointer=
 from integer without a cast
  udev->mb_addr =3D vzalloc(TCMU_RING_SIZE);
                ^
drivers/target/target_core_user.c:947:2: error: implicit declaration of fun=
ction 'vfree' [-Werror=3Dimplicit-function-declaration]
  vfree(udev->mb_addr);
  ^
drivers/target/iscsi/iscsi_target.c: In function 'iscsi_target_init_module':
drivers/target/iscsi/iscsi_target.c:557:2: error: implicit declaration of f=
unction 'vzalloc' [-Werror=3Dimplicit-function-declaration]
  iscsit_global->ts_bitmap =3D vzalloc(size);
  ^
drivers/target/iscsi/iscsi_target.c:557:27: warning: assignment makes point=
er from integer without a cast
  iscsit_global->ts_bitmap =3D vzalloc(size);
                           ^
drivers/target/iscsi/iscsi_target.c:615:2: error: implicit declaration of f=
unction 'vfree' [-Werror=3Dimplicit-function-declaration]
  vfree(iscsit_global->ts_bitmap);
  ^
drivers/scsi/qla2xxx/tcm_qla2xxx.c: In function 'tcm_qla2xxx_init_lport':
drivers/scsi/qla2xxx/tcm_qla2xxx.c:1578:2: error: implicit declaration of f=
unction 'vmalloc' [-Werror=3Dimplicit-function-declaration]
  lport->lport_loopid_map =3D vmalloc(sizeof(struct tcm_qla2xxx_fc_loopid) *
  ^
drivers/scsi/qla2xxx/tcm_qla2xxx.c:1578:26: warning: assignment makes point=
er from integer without a cast
  lport->lport_loopid_map =3D vmalloc(sizeof(struct tcm_qla2xxx_fc_loopid) *
                          ^
drivers/scsi/qla2xxx/tcm_qla2xxx.c: In function 'tcm_qla2xxx_make_lport':
drivers/scsi/qla2xxx/tcm_qla2xxx.c:1643:2: error: implicit declaration of f=
unction 'vfree' [-Werror=3Dimplicit-function-declaration]
  vfree(lport->lport_loopid_map);
  ^

Ouch :-(

Maybe commit 095dc8e0c368 ("tcp: fix/cleanup
inet_ehash_locks_alloc()")?  (that is the only commit I can find that
remove an include of vmalloc.h

Ah ha.  I applied this fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 28 May 2015 21:54:40 +1000
Subject: [PATCH] try putting the include of vmalloc.h back into inet_hashta=
bles.h

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/net/inet_hashtables.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index b73c88a19dd4..0046b9f91ed3 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -24,6 +24,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/wait.h>
+#include <linux/vmalloc.h>
=20
 #include <net/inet_connection_sock.h>
 #include <net/inet_sock.h>
--=20
2.1.4

So clearly there are people not reading Rule 1 in
Documentation/SubmitChecklist :-(
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Sig_/jr3v6dE4Xbwj_A_97xYdPCC
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVZwS3AAoJEMDTa8Ir7ZwVFnYP/3Ze84WjltmatFRjEKDwvtS+
HRuV75BmARp2EE1i8g9f7xQmlIhlc67dqoXTlMLqu3V9iDR1k/iWV4/xgGBp+OYK
7nryqK3xMrPN8LT0orHITlzm+K3NZExoKKAZZprddEMY+FR6FyOCAqajEeonHz6d
rxf1NP/cozhRtsl+dyAEvl2JYvJhREWqG1+9ToznAcY70wqI/ayhEBZY9mpM93rV
KaI17P8Zm6/wDAevibfPuZG4mRdQZ6OoQEGoOtCoZWoNR8zq6fg0CrE+i9q3cyNT
enPkJCDN/vVjIDVGQ/nR1LLxQyq7EuaNZLR4qNLp+/Uus0D9sDXwKyZFO85evXO/
if3/1a9HAPFRZ5rl0ibTE36rju9T/NUrFZHuQ6a3b4gWctmvwPtxkSIRZzXws23r
FfLHuvSHzFOUszkpMke/JPquJL7b2CdHtUl/jH6kH+3qm5v1gVQKPBYJI7ZG2xPe
E4VtUCUTIZljKDzDrYIIgLxbsgoYnlcBaaw6Y84BhAIUb0NsK0OyZKCUrzrpt1Ss
OVjPVXYMTMIIln+53sDmWLoJVTi5U+MtfmFs3L4CuOlUPHqGhJxTsZOJ2aBTciwh
4PWF17CCuF7yne2Rz9MXyFgWcs2VLgSxMYOTa6mYnhiVXJQ0XwzyXIaCgNDqRyFp
z65tjOQfoxs4cpLA2Hpv
=baqM
-----END PGP SIGNATURE-----

--Sig_/jr3v6dE4Xbwj_A_97xYdPCC--
