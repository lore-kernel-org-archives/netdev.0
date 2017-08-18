From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 2/3] vsock: fix vsock_dequeue/enqueue_accept race
Date: Fri, 18 Aug 2017 21:13:05 +0000
Message-ID: <KL1P15301MB0008245B174ABA9C85A49382BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB00082249964D8EF1BAA48790BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817140541.GH5539@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Haiyang Zhang" <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Jorgen Hansen <jhansen@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        Marcelo Cerri <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
        "joe@perches.com" <joe@perches.com>,
        "lin
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170817140541.GH5539@stefanha-x1.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Stefan Hajnoczi [mailto:stefanha@redhat.com]
> Sent: Thursday, August 17, 2017 07:06
>=20
> On Tue, Aug 15, 2017 at 10:15:39PM +0000, Dexuan Cui wrote:
> > With the current code, when vsock_dequeue_accept() is removing a sock
> > from the list, nothing prevents vsock_enqueue_accept() from adding a ne=
w
> > sock into the list concurrently. We should add a lock to protect the li=
st.
>=20
> The listener sock is locked, preventing concurrent modification.  I have
> checked both the virtio and vmci transports.  Can you post an example
> where the listener sock isn't locked?
>=20
> Stefan
Sorry, I was not careful when checking the vmci code.=20
Please ignore the patch.

Now I realized the expectation is that the individual transport drivers sho=
uld
do the locking for vsock_enqueue_accept(), but for vsock_dequeue_accept(),
the locking is done by the common vsock driver.

Thanks,
-- Dexuan
