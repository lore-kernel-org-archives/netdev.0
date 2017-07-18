From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: [PATCH] wireless: wext: terminate ifr name coming from userspace
Date: Tue, 18 Jul 2017 04:23:16 +0000
Message-ID: <20170718042318.5309-1-alexander.levin@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
To: "johannes.berg@intel.com" <johannes.berg@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ifr name is assumed to be a valid string by the kernel, but nothing
was forcing username to pass a valid string.

In turn, this would cause panics as we tried to access the string
past it's valid memory.

Signed-off-by: Sasha Levin <alexander.levin@verizon.com>
---
 net/core/dev_ioctl.c   | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

index 82fd4c9c4a1b..7657ad6bc13d 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -424,6 +424,8 @@ int dev_ioctl(struct net *net, unsigned int cmd, void _=
_user *arg)
 		if (copy_from_user(&iwr, arg, sizeof(iwr)))
 			return -EFAULT;
=20
+		iwr.ifr_name[sizeof(iwr.ifr_name) - 1] =3D 0;
+
 		return wext_handle_ioctl(net, &iwr, cmd, arg);
 	}
=20
--=20
2.11.0
