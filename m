From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: replace
	netdev_alloc_skb_ip_align() with napi_alloc_skb()
Date: Fri, 18 Mar 2016 09:21:41 +0100
Message-ID: <1458289301.5314.11.camel@redhat.com>
References: <b436c3eb5d4c19e92184c27d89ec8118d6fd3f81.1458224603.git.pabeni@redhat.com>
	<CAHdzE-_u35Kg1zck1KKCYhu5epx4vNtzE7UX41Bi85vsJ55ROw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: Venkatesh Srinivas <venkateshs@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAHdzE-_u35Kg1zck1KKCYhu5epx4vNtzE7UX41Bi85vsJ55ROw@mail.gmail.com>
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

On Thu, 2016-03-17 at 18:01 -0700, Venkatesh Srinivas wrote:
> On Thu, Mar 17, 2016 at 7:44 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> >
> > This gives small but noticeable rx performance improvement (2-3%)
> > and will allow exploiting future napi improvement.
> >
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> 
> Worked in my tests, though the performance win was in the noise (+0.6%
> - +1% bandwidth).
> What tests did you see a 2-3% win on?

I'm doing net2VM tests (i.e. the traffic generator is on a different
host) with guest tuned a bit for performance. i.e. cpu pinning, no
iptables, no dhclient (yes, that makes a big difference:
http://lists.openwall.net/netdev/2013/10/29/5)

> Do you think its worth modifying add_recvbuf_small() to use
> napi_alloc_skb() when called from
> Rx NAPI (virtnet_receive)?

Oops, I missed that invocation. Probably that path is not hit in my
test. I think it should be really worthy.

I'll send a v2.

The important thing, more than the current improvement, is allowing the
virtio_net driver to leverage future napi allocation improvement (i.e.
bulk alloc: http://www.spinics.net/lists/netdev/msg367568.html) which
should be a real win.

Paolo
