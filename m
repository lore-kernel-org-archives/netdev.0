From: Wang Shanker <shankerwangmiao@gmail.com>
Subject: [Question] Should `CAP_NET_ADMIN` be needed when opening `/dev/ppp`?
Date: Sun, 1 May 2016 21:38:57 +0800
Message-ID: <2BEB0C68-EBC6-4A8F-A751-DE8F4A2C9D2C@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, all.

                                                                       =
       =20
I=A1=AFve recently met some problems when trying to create a pppoe netw=
ork link=20
inside a unprivileged container. There is a uid namespace which maps ro=
ot=20
inside to a normal user outside. There is also a separate net namespace=
 in the=20
container. I create a dev node inside the container and set right=20
permission.   =20

However, `/dev/ppp` cannot get opened since the mapped normal user does=
 not=20
have `CAP_NET_ADMIN`. The related code is in `drivers/net/ppp/ppp_gener=
ic.c`:=20
`int ppp_open()`=20

```
static int ppp_open(struct inode *inode, struct file *file)
{
	/*
	 * This could (should?) be enforced by the permissions on /dev/ppp.
	 */
	if (!capable(CAP_NET_ADMIN))
		return -EPERM;
	return 0;
}
```

I wonder why CAP_NET_ADMIN is needed here, rather than leaving it to th=
e
permission of the device node. If there is no need, I suggest that the=20
CAP_NET_ADMIN check be removed.=20
