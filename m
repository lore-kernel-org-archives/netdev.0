From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: use per-receive queue page frag
	alloc for mergeable bufs
Date: Wed, 08 Jan 2014 13:16:44 -0800
Message-ID: <52CDC03C.8070509@hp.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<1387239389-13216-2-git-send-email-mwdalton@google.com>
	<52B7F065.3010707@redhat.com>
	<1387819627.12212.4.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131223193704.GC1582@redhat.com>
	<CANJ5vPLEV_Z-D-0tThwhWXbHVaRWOLv566Xk1eD4TNYqNvknHw@mail.gmail.com>
	<20131226213727.GA10259@redhat.com>
	<1388095258.12212.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140108172104.GD17404@redhat.com>
	<1389204587.26646.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389204587.26646.111.camel@edumazet-glaptop2.roam.corp.google.com>
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

On 01/08/2014 10:09 AM, Eric Dumazet wrote:
> In normal networking land, when a host A sends frames to host B,
> nothing prevents A to pause the traffic to B if B is dropping packets
> under stress.
>
> A physical NIC do not use a workqueue to refill its RX queue but uses
> the following strategy :
>
> 0) Pre filling of RX ring buffer with N frames. This can use GFP_KERNEL
>     allocations with all needed (sleep/retry/shout) logic...
> 1) IRQ is handled.
> 2) Can we allocate a new buffer (GFP_ATOMIC) ?
>     If yes, we accept the frame,
>        and post the new buffer for the 'next frame'
>     If no, we drop the frame and recycle the memory for next round.

          and increment a suitably specific statistic so someone trying 
to diagnose performance/other problems can know we dropped the frame.

rick jones
