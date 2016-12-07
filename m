From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 10/10] virtio: enable endian checks for sparse builds
Date: Wed, 7 Dec 2016 15:22:14 +0200
Message-ID: <20161207152131-mutt-send-email-mst@kernel.org>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-11-git-send-email-mst@redhat.com>
	<1481091951.4092.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: kvm@vger.kernel.org, Neil Armstrong <narmstrong@baylibre.com>,
	David Airlie <airlied@linux.ie>, linux-remoteproc@vger.kernel.org,
	dri-devel@lists.freedesktop.org, virtualization@lists.linux-foundation.org,
	linux-s390@vger.kernel.org,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-scsi@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	Asias He <asias@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	linux-kbuild@vger.kernel.org, Jens Axboe <axboe@fb.com>,
	Michal Marek <mmarek@suse.com>, Stefan Hajnoczi <stefanha@redhat.com>,
	Matt Mackall <mpm@selenic.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1481091951.4092.12.camel@sipsolutions.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2016 at 07:25:51AM +0100, Johannes Berg wrote:
> On Tue, 2016-12-06 at 17:41 +0200, Michael S. Tsirkin wrote:
> =

> > It seems that there should be a better way to do it,
> > but this works too.
> =

> In some cases there might be:
> =

> > --- a/drivers/s390/virtio/Makefile
> > +++ b/drivers/s390/virtio/Makefile
> > @@ -6,6 +6,8 @@
> > =A0# it under the terms of the GNU General Public License (version 2
> > only)
> > =A0# as published by the Free Software Foundation.
> > =A0
> > +CFLAGS_virtio_ccw.o +=3D -D__CHECK_ENDIAN__
> > +CFLAGS_kvm_virtio.o +=3D -D__CHECK_ENDIAN__
> > =A0s390-virtio-objs :=3D virtio_ccw.o
> > =A0ifdef CONFIG_S390_GUEST_OLD_TRANSPORT
> > =A0s390-virtio-objs +=3D kvm_virtio.o
> =

> Here you could use
> =

> ccflags-y +=3D -D__CHECK_ENDIAN__
> =

> for example, or even
> =

> subdir-ccflags-y +=3D -D__CHECK_ENDIAN__
> =

> (in case any subdirs ever get added here)

Oh right. I forgot this directory only has virtio stuff.

> > --- a/drivers/vhost/Makefile
> > +++ b/drivers/vhost/Makefile
> > @@ -1,3 +1,4 @@
> > +ccflags-y :=3D -D__CHECK_ENDIAN__
> =

> Looks like you did that here and in some other places though - so
> perhaps the s390 one was intentionally different?
> =

> > --- a/net/packet/Makefile
> > +++ b/net/packet/Makefile
> > @@ -2,6 +2,7 @@
> > =A0# Makefile for the packet AF.
> > =A0#
> > =A0
> > +ccflags-y :=3D -D__CHECK_ENDIAN__
> =

> Technically this is slightly more than advertised, but I guess that
> still makes sense if it's clean now.
> =

> johannes
