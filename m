From: Liu ping fan <kernelfans@gmail.com>
Subject: net-sched/vhost-net: Besides Qdisc on host,
 is it worth to have a try for tranfic control on vhost-net device?
Date: Mon, 16 Apr 2012 14:45:30 +0800
Message-ID: <CAFgQCTsXfs-QAgMp1nfEu=pzhyO763ZQ7XoY7jS9XkjZv0Vxww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefan Hajnoczi <stefanha@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, Anthony Liguori <anthony@codemonkey.ws>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org, qemu-devel@nongnu.org
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Hi guys,

Nowadays, in order to limit the guest's TX bandwidth, we can apply tc
on tap device's ingress Qdisc on host. But I think it is based on
dropping packets in the host's Qdisc layer(Right?).
If my assumption is right, then on guest, whether the sender process
will lower its output or not, will depend on protocol layer implement.
As to protocol armed with congestion control such as tcp, the sender
process will block and save cpu. But as to udp, it seems that the
sender process just generate some unnecessary dropped packets.
In order to save cpu, we can introduce control vhost-net, then the
guest udp sender will block on sk.sk_wmem_alloc to get the same effect
as blocking on congestion like tcp.

But all of above are based on the Qdisc layer's behavior when network
over-limit on host. Is it simply drop skb or defer its transferring?
If deferring, any example code?

Any comments?

Thanks and regards,
pingfan
