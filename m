From: Helge Deller <deller@gmx.de>
Subject: CONFIG_XPS depends on L1_CACHE_BYTES being greater than sizeof(struct
 xps_map)
Date: Thu, 22 Oct 2015 22:00:11 +0200
Message-ID: <5629404B.8090805@gmx.de>
References: <42430464-867C-4E0B-8E95-C6CDB6D8A0B2@bell.net>
 <32A3BF6F-B243-4AD4-9AE9-A5F9DAE0270A@bell.net>
 <B8E85737-5ECD-4CBE-8730-886B098C5FA4@bell.net>
 <trinity-eda7d55d-7234-4b29-a15c-955f8ba0c95e-1445513884942@3capp-gmx-bs32>
 <trinity-8980ad10-b889-45cf-8f37-a33ba9cf99ef-1445514797080@3capp-gmx-bs32>
 <1445524549.2207.1.camel@HansenPartnership.com> <5628F868.3040105@bell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	John David Anglin <dave.anglin@bell.net>
To: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <5628F868.3040105@bell.net>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tom & David,

I've queued-up a patch for the parisc architecture which reduces L1_CAC=
HE_BYTES from 32 to 16:
  https://patchwork.kernel.org/patch/7399291/

But this change will break the kernel build like this:

In file included from net/core/dev.c:92:0:
net/core/dev.c: In function =E2=80=98expand_xps_map=E2=80=99:
include/linux/netdevice.h:721:27: warning: overflow in implicit constan=
t conversion [-Woverflow]
   #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map))=
 \
net/core/dev.c:1972:18: note: in expansion of macro =E2=80=98XPS_MIN_MA=
P_ALLOC=E2=80=99
   int alloc_len =3D XPS_MIN_MAP_ALLOC;

Do you see an easy way to fix this ?

Thanks,
Helge=20
--
To unsubscribe from this list: send the line "unsubscribe linux-parisc"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
