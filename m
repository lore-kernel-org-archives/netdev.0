From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH stable 1/2] virtio_net: fix error handling for mergeable
	buffers
Date: Wed, 25 Dec 2013 21:19:32 +0200
Message-ID: <20131225191932.GB22071@redhat.com>
References: <1387983339-1172-1-git-send-email-mst@redhat.com>
	<1387983339-1172-2-git-send-email-mst@redhat.com>
	<CANJ5vPK-rs2d_TvZ3wuAXMK8ctoSvg2km8MpncMU+0cdk=TAsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, David Miller <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CANJ5vPK-rs2d_TvZ3wuAXMK8ctoSvg2km8MpncMU+0cdk=TAsw@mail.gmail.com>
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

On Wed, Dec 25, 2013 at 10:33:37AM -0800, Michael Dalton wrote:
> Hi Michael, quick question below:
> 
> On Wed, Dec 25, 2013 at 6:56 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >                 if (i >= MAX_SKB_FRAGS) {
> >                         pr_debug("%s: packet too long\n", skb->dev->name);
> >                         skb->dev->stats.rx_length_errors++;
> > -                       return -EINVAL;
> > +                       return NULL;
> >                 }
> 
> Should this error handling path free the SKB before returning NULL?
> It seems like if we just return NULL we may leak memory.
> 
> Best,
> 
> Mike

It's a device error, but
I agree, if we touch this code anyway there's no reason not to handle
this consistently and do goto toward end of file.
It's not a backport anymore though - this code is gone upstream,
so I'll make it a separate patch I think.

-- 
MST
