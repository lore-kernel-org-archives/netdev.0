From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 2/3] vsock: fix vsock_dequeue/enqueue_accept race
Date: Fri, 18 Aug 2017 00:37:47 +0000
Message-ID: <KL1P15301MB0008382F3BE8EE3313C103FEBF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB00082249964D8EF1BAA48790BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <E062F976-DF33-46CB-AB17-07F014AE138A@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "Stephen Hemminger" <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        "Marcelo Cerri" <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
        "joe@perches.com" <joe@perches
To: "Jorgen S. Hansen" <jhansen@vmware.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E062F976-DF33-46CB-AB17-07F014AE138A@vmware.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > On Aug 16, 2017, at 12:15 AM, Dexuan Cui <decui@microsoft.com> wrote:
> > With the current code, when vsock_dequeue_accept() is removing a sock
> > from the list, nothing prevents vsock_enqueue_accept() from adding a ne=
w
> > sock into the list concurrently. We should add a lock to protect the li=
st.
>=20
> For the VMCI socket transport, we always lock the sockets before calling =
into
> vsock_enqueue_accept and af_vsock.c locks the socket before calling
> vsock_dequeue_accept, so from our point of view these operations are alre=
ady
> protected, but with finer granularity than a single global lock. As far a=
s I can see,
> the virtio transport also locks the socket before calling vsock_enqueue_a=
ccept,
> so they should be fine with the current version as well, but Stefan can c=
omment
> on that.
>=20
> Jorgen

Hi Jorgen,
Thanks, you're correct.
Please ignore this patch. I'll update the hv_sock driver to add proper=20
lock_sock()/relesae_sock().

Thanks,
-- Dexuan
