From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC v4 net-next 0/5] virtio_net: enabling tx interrupts
Date: Tue, 2 Dec 2014 10:00:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA007CC@AcuExch.aculab.com>
References: <1417429028-11971-1-git-send-email-jasowang@redhat.com>
	<20141201104223.GB16108@redhat.com>
	<1417490120.4405.2@smtp.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "pagupta@redhat.com" <pagupta@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: 'Jason Wang' <jasowang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417490120.4405.2@smtp.corp.redhat.com>
Content-Language: en-US
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

From: Jason Wang
> > On Mon, Dec 01, 2014 at 06:17:03PM +0800, Jason Wang wrote:
> >>  Hello:
> >>
> >>  We used to orphan packets before transmission for virtio-net. This
> >> breaks
> >>  socket accounting and can lead serveral functions won't work, e.g:
> >>
> >>  - Byte Queue Limit depends on tx completion nofication to work.
> >>  - Packet Generator depends on tx completion nofication for the last
> >>    transmitted packet to complete.
> >>  - TCP Small Queue depends on proper accounting of sk_wmem_alloc to
> >> work.
> >>
> >>  This series tries to solve the issue by enabling tx interrupts. To
> >> minize
> >>  the performance impacts of this, several optimizations were used:
> >>
> >>  - In guest side, virtqueue_enable_cb_delayed() was used to delay the tx
> >>    interrupt untile 3/4 pending packets were sent.

Doesn't that give problems for intermittent transmits?

...

	David
