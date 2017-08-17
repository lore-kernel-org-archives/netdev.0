From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH net-next 2/3] vsock: fix vsock_dequeue/enqueue_accept race
Date: Thu, 17 Aug 2017 12:43:23 +0000
Message-ID: <E062F976-DF33-46CB-AB17-07F014AE138A@vmware.com>
References: <KL1P15301MB00082249964D8EF1BAA48790BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Haiyang Zhang" <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>, Asias He <asias@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        "Vitaly Kuznetsov" <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        "Marcelo Cerri" <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <KL1P15301MB00082249964D8EF1BAA48790BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-ID: <6FA8E0297FF38E4881DFBF823706D562@namprd05.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Aug 16, 2017, at 12:15 AM, Dexuan Cui <decui@microsoft.com> wrote:
>=20
>=20
> With the current code, when vsock_dequeue_accept() is removing a sock
> from the list, nothing prevents vsock_enqueue_accept() from adding a new
> sock into the list concurrently. We should add a lock to protect the list=
.
>=20

For the VMCI socket transport, we always lock the sockets before calling in=
to vsock_enqueue_accept and af_vsock.c locks the socket before calling vsoc=
k_dequeue_accept, so from our point of view these operations are already pr=
otected, but with finer granularity than a single global lock. As far as I =
can see, the virtio transport also locks the socket before calling vsock_en=
queue_accept, so they should be fine with the current version as well, but =
Stefan can comment on that.

Thanks,
Jorgen=
