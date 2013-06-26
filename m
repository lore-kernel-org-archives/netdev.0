From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Wed, 26 Jun 2013 17:56:10 +1000
Message-ID: <20130626175610.8a8b6606fd9a5b6269398059@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__26_Jun_2013_17_56_10_+1000_o8w9zzheYWHHBYrb"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__26_Jun_2013_17_56_10_+1000_o8w9zzheYWHHBYrb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

In file included from arch/powerpc/include/asm/dma-mapping.h:123:0,
                 from include/linux/dma-mapping.h:76,
                 from include/linux/skbuff.h:33,
                 from include/linux/if_ether.h:23,
                 from include/linux/etherdevice.h:25,
                 from drivers/net/ethernet/arc/emac_main.c:16:
drivers/net/ethernet/arc/emac_main.c: In function 'arc_emac_tx_clean':
include/linux/dma-mapping.h:227:56: error: request for member 'addr' in som=
ething not a structure or union
 #define dma_unmap_addr(PTR, ADDR_NAME)           ((PTR)->ADDR_NAME)
                                                        ^
include/asm-generic/dma-mapping-common.h:175:64: note: in definition of mac=
ro 'dma_unmap_single'
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NU=
LL)
                                                                ^
drivers/net/ethernet/arc/emac_main.c:174:32: note: in expansion of macro 'd=
ma_unmap_addr'
   dma_unmap_single(&ndev->dev, dma_unmap_addr(&tx_buff, addr),
                                ^
include/linux/dma-mapping.h:229:56: error: request for member 'len' in some=
thing not a structure or union
 #define dma_unmap_len(PTR, LEN_NAME)             ((PTR)->LEN_NAME)
                                                        ^
include/asm-generic/dma-mapping-common.h:175:67: note: in definition of mac=
ro 'dma_unmap_single'
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NU=
LL)
                                                                   ^
drivers/net/ethernet/arc/emac_main.c:175:6: note: in expansion of macro 'dm=
a_unmap_len'
      dma_unmap_len(&tx_buff, len), DMA_TO_DEVICE);
      ^
drivers/net/ethernet/arc/emac_main.c: In function 'arc_emac_rx':
include/linux/dma-mapping.h:227:56: error: request for member 'addr' in som=
ething not a structure or union
 #define dma_unmap_addr(PTR, ADDR_NAME)           ((PTR)->ADDR_NAME)
                                                        ^
include/asm-generic/dma-mapping-common.h:175:64: note: in definition of mac=
ro 'dma_unmap_single'
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NU=
LL)
                                                                ^
drivers/net/ethernet/arc/emac_main.c:243:32: note: in expansion of macro 'd=
ma_unmap_addr'
   dma_unmap_single(&ndev->dev, dma_unmap_addr(&rx_buff, addr),
                                ^
include/linux/dma-mapping.h:229:56: error: request for member 'len' in some=
thing not a structure or union
 #define dma_unmap_len(PTR, LEN_NAME)             ((PTR)->LEN_NAME)
                                                        ^
include/asm-generic/dma-mapping-common.h:175:67: note: in definition of mac=
ro 'dma_unmap_single'
 #define dma_unmap_single(d, a, s, r) dma_unmap_single_attrs(d, a, s, r, NU=
LL)
                                                                   ^
drivers/net/ethernet/arc/emac_main.c:244:6: note: in expansion of macro 'dm=
a_unmap_len'
      dma_unmap_len(&rx_buff, len), DMA_FROM_DEVICE);
      ^
In file included from include/linux/skbuff.h:33:0,
                 from include/linux/if_ether.h:23,
                 from include/linux/etherdevice.h:25,
                 from drivers/net/ethernet/arc/emac_main.c:16:
include/linux/dma-mapping.h:228:57: error: request for member 'mapping' in =
something not a structure or union
 #define dma_unmap_addr_set(PTR, ADDR_NAME, VAL)  (((PTR)->ADDR_NAME) =3D (=
VAL))
                                                         ^
drivers/net/ethernet/arc/emac_main.c:267:3: note: in expansion of macro 'dm=
a_unmap_addr_set'
   dma_unmap_addr_set(&rx_buff, mapping, addr);
   ^
include/linux/dma-mapping.h:230:57: error: request for member 'len' in some=
thing not a structure or union
 #define dma_unmap_len_set(PTR, LEN_NAME, VAL)    (((PTR)->LEN_NAME) =3D (V=
AL))
                                                         ^
drivers/net/ethernet/arc/emac_main.c:268:3: note: in expansion of macro 'dm=
a_unmap_len_set'
   dma_unmap_len_set(&rx_buff, len, buflen);
   ^
In file included from include/linux/swab.h:4:0,
                 from include/uapi/linux/byteorder/big_endian.h:12,
                 from include/linux/byteorder/big_endian.h:4,
                 from arch/powerpc/include/uapi/asm/byteorder.h:10,
                 from include/asm-generic/bitops/le.h:5,
                 from arch/powerpc/include/asm/bitops.h:278,
                 from include/linux/bitops.h:22,
                 from include/linux/kernel.h:10,
                 from include/linux/skbuff.h:17,
                 from include/linux/if_ether.h:23,
                 from include/linux/etherdevice.h:25,
                 from drivers/net/ethernet/arc/emac_main.c:16:
include/uapi/linux/swab.h:115:24: warning: cast from pointer to integer of =
different size [-Wpointer-to-int-cast]
  (__builtin_constant_p((__u32)(x)) ? \
                        ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:270:16: note: in expansion of macro 'c=
pu_to_le32'
   rxbd->data =3D cpu_to_le32(rx_buff->skb->data);
                ^
include/uapi/linux/swab.h:17:4: warning: cast from pointer to integer of di=
fferent size [-Wpointer-to-int-cast]
  (((__u32)(x) & (__u32)0x000000ffUL) << 24) |  \
    ^
include/uapi/linux/swab.h:116:2: note: in expansion of macro '___constant_s=
wab32'
  ___constant_swab32(x) :   \
  ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:270:16: note: in expansion of macro 'c=
pu_to_le32'
   rxbd->data =3D cpu_to_le32(rx_buff->skb->data);
                ^
include/uapi/linux/swab.h:18:4: warning: cast from pointer to integer of di=
fferent size [-Wpointer-to-int-cast]
  (((__u32)(x) & (__u32)0x0000ff00UL) <<  8) |  \
    ^
include/uapi/linux/swab.h:116:2: note: in expansion of macro '___constant_s=
wab32'
  ___constant_swab32(x) :   \
  ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:270:16: note: in expansion of macro 'c=
pu_to_le32'
   rxbd->data =3D cpu_to_le32(rx_buff->skb->data);
                ^
include/uapi/linux/swab.h:19:4: warning: cast from pointer to integer of di=
fferent size [-Wpointer-to-int-cast]
  (((__u32)(x) & (__u32)0x00ff0000UL) >>  8) |  \
    ^
include/uapi/linux/swab.h:116:2: note: in expansion of macro '___constant_s=
wab32'
  ___constant_swab32(x) :   \
  ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:270:16: note: in expansion of macro 'c=
pu_to_le32'
   rxbd->data =3D cpu_to_le32(rx_buff->skb->data);
                ^
include/uapi/linux/swab.h:20:4: warning: cast from pointer to integer of di=
fferent size [-Wpointer-to-int-cast]
  (((__u32)(x) & (__u32)0xff000000UL) >> 24)))
    ^
include/uapi/linux/swab.h:116:2: note: in expansion of macro '___constant_s=
wab32'
  ___constant_swab32(x) :   \
  ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:270:16: note: in expansion of macro 'c=
pu_to_le32'
   rxbd->data =3D cpu_to_le32(rx_buff->skb->data);
                ^
drivers/net/ethernet/arc/emac_main.c:270:3: warning: passing argument 1 of =
'__fswab32' makes integer from pointer without a cast [enabled by default]
   rxbd->data =3D cpu_to_le32(rx_buff->skb->data);
   ^
In file included from include/linux/swab.h:4:0,
                 from include/uapi/linux/byteorder/big_endian.h:12,
                 from include/linux/byteorder/big_endian.h:4,
                 from arch/powerpc/include/uapi/asm/byteorder.h:10,
                 from include/asm-generic/bitops/le.h:5,
                 from arch/powerpc/include/asm/bitops.h:278,
                 from include/linux/bitops.h:22,
                 from include/linux/kernel.h:10,
                 from include/linux/skbuff.h:17,
                 from include/linux/if_ether.h:23,
                 from include/linux/etherdevice.h:25,
                 from drivers/net/ethernet/arc/emac_main.c:16:
include/uapi/linux/swab.h:57:41: note: expected '__u32' but argument is of =
type 'unsigned char *'
 static inline __attribute_const__ __u32 __fswab32(__u32 val)
                                         ^
drivers/net/ethernet/arc/emac_main.c: In function 'arc_emac_open':
include/uapi/linux/swab.h:115:24: warning: cast from pointer to integer of =
different size [-Wpointer-to-int-cast]
  (__builtin_constant_p((__u32)(x)) ? \
                        ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:406:14: note: in expansion of macro 'c=
pu_to_le32'
   bd->data =3D cpu_to_le32(skb->data);
              ^
include/uapi/linux/swab.h:17:4: warning: cast from pointer to integer of di=
fferent size [-Wpointer-to-int-cast]
  (((__u32)(x) & (__u32)0x000000ffUL) << 24) |  \
    ^
include/uapi/linux/swab.h:116:2: note: in expansion of macro '___constant_s=
wab32'
  ___constant_swab32(x) :   \
  ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:406:14: note: in expansion of macro 'c=
pu_to_le32'
   bd->data =3D cpu_to_le32(skb->data);
              ^
include/uapi/linux/swab.h:18:4: warning: cast from pointer to integer of di=
fferent size [-Wpointer-to-int-cast]
  (((__u32)(x) & (__u32)0x0000ff00UL) <<  8) |  \
    ^
include/uapi/linux/swab.h:116:2: note: in expansion of macro '___constant_s=
wab32'
  ___constant_swab32(x) :   \
  ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:406:14: note: in expansion of macro 'c=
pu_to_le32'
   bd->data =3D cpu_to_le32(skb->data);
              ^
include/uapi/linux/swab.h:19:4: warning: cast from pointer to integer of di=
fferent size [-Wpointer-to-int-cast]
  (((__u32)(x) & (__u32)0x00ff0000UL) >>  8) |  \
    ^
include/uapi/linux/swab.h:116:2: note: in expansion of macro '___constant_s=
wab32'
  ___constant_swab32(x) :   \
  ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:406:14: note: in expansion of macro 'c=
pu_to_le32'
   bd->data =3D cpu_to_le32(skb->data);
              ^
include/uapi/linux/swab.h:20:4: warning: cast from pointer to integer of di=
fferent size [-Wpointer-to-int-cast]
  (((__u32)(x) & (__u32)0xff000000UL) >> 24)))
    ^
include/uapi/linux/swab.h:116:2: note: in expansion of macro '___constant_s=
wab32'
  ___constant_swab32(x) :   \
  ^
include/uapi/linux/byteorder/big_endian.h:32:43: note: in expansion of macr=
o '__swab32'
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                                           ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu=
_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/net/ethernet/arc/emac_main.c:406:14: note: in expansion of macro 'c=
pu_to_le32'
   bd->data =3D cpu_to_le32(skb->data);
              ^
drivers/net/ethernet/arc/emac_main.c:406:3: warning: passing argument 1 of =
'__fswab32' makes integer from pointer without a cast [enabled by default]
   bd->data =3D cpu_to_le32(skb->data);
   ^
In file included from include/linux/swab.h:4:0,
                 from include/uapi/linux/byteorder/big_endian.h:12,
                 from include/linux/byteorder/big_endian.h:4,
                 from arch/powerpc/include/uapi/asm/byteorder.h:10,
                 from include/asm-generic/bitops/le.h:5,
                 from arch/powerpc/include/asm/bitops.h:278,
                 from include/linux/bitops.h:22,
                 from include/linux/kernel.h:10,
                 from include/linux/skbuff.h:17,
                 from include/linux/if_ether.h:23,
                 from include/linux/etherdevice.h:25,
                 from drivers/net/ethernet/arc/emac_main.c:16:
include/uapi/linux/swab.h:57:41: note: expected '__u32' but argument is of =
type 'unsigned char *'
 static inline __attribute_const__ __u32 __fswab32(__u32 val)
                                         ^
In file included from include/linux/skbuff.h:33:0,
                 from include/linux/if_ether.h:23,
                 from include/linux/etherdevice.h:25,
                 from drivers/net/ethernet/arc/emac_main.c:16:
drivers/net/ethernet/arc/emac_main.c: In function 'arc_emac_tx':
include/linux/dma-mapping.h:228:57: error: 'struct buffer_state' has no mem=
ber named 'mapping'
 #define dma_unmap_addr_set(PTR, ADDR_NAME, VAL)  (((PTR)->ADDR_NAME) =3D (=
VAL))
                                                         ^
drivers/net/ethernet/arc/emac_main.c:546:2: note: in expansion of macro 'dm=
a_unmap_addr_set'
  dma_unmap_addr_set(&priv->tx_buff[*txbd_curr], mapping, addr);
  ^

Caused by commit e4f2379db6c6 ("ethernet/arc/arc_emac - Add new driver")
from the net-next tree.

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__26_Jun_2013_17_56_10_+1000_o8w9zzheYWHHBYrb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRyp6fAAoJEECxmPOUX5FErJ0P/1xDO1u8v63LMrF0dQms+hob
88QvDMvzL2ZM+42jzQWfnXX+lBWfdQGTXC1rt/zq5FcBIhvaVYTRBEpiQ5mUGrQw
/98iHEcN7Kqv6U0NXlQCMV9kqZKhv1xoJCR1G9R6EIqAcBVNZCS8byHDKUq/9In3
BgSRE1Pcke3AplEPaC9lEzFnqeMLFhW3rD8g3VEnVeaYv4pLj5y1cpmDEh9GeliJ
X5CsRncrck0k6A3IzALQjaBvSbI3ZF5RSHS80TYyKYXmneDug9WG0uQ28GXtJbUu
ph5ogyfqsVBTyhpERDm60zED36QmeQi3xnakF+T6MN0GVCY96NlRdiI2tqxyDqxk
ksvFk/fQec1fr0PxwLBoHP5P/+0CDpBmvPUgDlKJakun1hGYkQBmaMxxbZ7X0cmT
W6VcOD7eNrjfuM8x4RyKiZNPn7HvhWv4vbNPhrIHC7/iRWOwdgQ6q9xY7vdtP1hf
xrK/OG56eB3y1B+tvH9H+vteYaqMu+MPTdqBSKsTuoMXdakEO+LsgdTVo910pwxN
mjy+KXB/Hg5V5FyE5AsJ3o3BQA0oF7CMLQLy1uwQG5ArGj2YPc3VV9hOf2+AtJPZ
cGRsUhXVsvE409Hu2H2ojwJpMY4BJJRwtV2Oy6T957uc/7xTINV0U0z8XF2aaKO3
jfqdnMD9ZzDl6wFWdj3L
=hK27
-----END PGP SIGNATURE-----

--Signature=_Wed__26_Jun_2013_17_56_10_+1000_o8w9zzheYWHHBYrb--
