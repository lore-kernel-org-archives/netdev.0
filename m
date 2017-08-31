From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Thu, 31 Aug 2017 12:54:55 +0100
Message-ID: <20170831115455.GP13619@stefanha-x1.localdomain>
References: <20170817135559.GG5539@stefanha-x1.localdomain>
 <04460E3B-B213-4090-96CD-00CEEBE6AC32@vmware.com>
 <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170818153716.GB17572@stefanha-x1.localdomain>
 <KL1P15301MB00083B1F5B70CBAB7C42BBD3BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170822095437.GB16799@stefanha-x1.localdomain>
 <A6BE88A8-6E79-486E-821F-0D5C8B1B3034@vmware.com>
 <KL1P15301MB000812AD1EFB8A3986EC6277BF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <KL1P15301MB0008087A3EF0A8D037CC4D52BF9F0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <61AE41B3-D143-46D2-8C68-009B78AF12C8@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 George Zhang <georgezhang@vmware.com>,
 Stephen Hemminger <sthemmin@microsoft.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 Marcelo Cerri <marcelo.cerri@canonical.com>, Asias He <asias@redhat.com>,
 Dan Carpenter <dan.carpenter@oracle.com>, "olaf@aepfle.de" <olaf@aepfle.de>,
 Haiyang Zhang <haiyangz@microsoft.com>, Dave Scott <dave.scott@docker.com>,
 "apw@canonical.com" <apw@canonical.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "joe@perches.com" <joe@perches.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Vitaly Kuznetsov <vkuznets@redhat.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <61AE41B3-D143-46D2-8C68-009B78AF12C8@vmware.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2017 at 03:37:07PM +0000, Jorgen S. Hansen wrote:
> > On Aug 29, 2017, at 4:36 AM, Dexuan Cui <decui@microsoft.com> wrote:
> If we allow multiple host side transports, virtio host side support and
> vmci should be able to coexist regardless of the order of initialization.

That sounds good to me.

This means af_vsock.c needs to be aware of CID allocation.  Currently the
vhost_vsock.ko driver handles this itself (it keeps a list of CIDs and
checks that they are not used twice).  It should be possible to move
that state into af_vsock.c so we have <cid, host_transport> pairs.

I'm currently working on NFS over AF_VSOCK and sock_diag support (for
ss(8) and netstat-like tools).

Multi-transport support is lower priority for me at the moment.  I'm
happy to review patches though.  If there is no progress on this by the
end of the year then I will have time to work on it.

Are either of you are in Prague, Czech Republic on October 25-27 for
Linux Kernel Summit, Open Source Summit Europe, Embedded Linux
Conference Europe, KVM Forum, or MesosCon Europe?

Stefan
