From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 1/2] vhost_net: stop polling socket during rx processing
Date: Tue, 07 Jun 2016 14:46:33 -0700 (PDT)
Message-ID: <20160607.144633.1372446059350476794.davem@davemloft.net>
References: <1464760594-30326-1-git-send-email-jasowang@redhat.com>
	<1464760594-30326-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1464760594-30326-2-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Wed,  1 Jun 2016 01:56:33 -0400

> We don't stop rx polling socket during rx processing, this will lead
> unnecessary wakeups from under layer net devices (E.g
> sock_def_readable() form tun). Rx will be slowed down in this
> way. This patch avoids this by stop polling socket during rx
> processing. A small drawback is that this introduces some overheads in
> light load case because of the extra start/stop polling, but single
> netperf TCP_RR does not notice any change. In a super heavy load case,
> e.g using pktgen to inject packet to guest, we get about ~8.8%
> improvement on pps:
> 
> before: ~1240000 pkt/s
> after:  ~1350000 pkt/s
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
