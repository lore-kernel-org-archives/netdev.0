From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
	export mergeable rx buffer size
Date: Fri, 10 Jan 2014 21:36:53 -0800
Message-ID: <CANJ5vPLzDr9J4MXiamkTxGBAEnVoyWPvUvG9+KyAFGf6XV+S7w@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-4-git-send-email-mwdalton@google.com>
	<52CCF177.7020500@redhat.com> <20140108192109.GC18312@redhat.com>
	<CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
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

Also, one other note: if we use sysfs, the directory structure will
be different depending on our chosen sysfs strategy. If we augment
netdev_rx_queue, the new attributes will be found in the standard
'rx-<N>' netdev subdirectory, e.g.,
/sys/class/net/eth0/queues/rx-0/mergeable_rx_buffer_size

Whereas if we use per-netdev attributes, our attributes would be in
/sys/class/net/eth0/<group name>/<attribute name>, which may be
less intuitive as AFAICT we'd have to indicate both the queue # and
type of value being reported using the attribute name. E.g.,
/sys/class/net/eth0/virtio-net/rx-0_mergeable_buffer_size.
That's somewhat less elegant.

I don't see an easy way to add new attributes to the 'rx-<N>'
subdirectories without directly modifying struct netdev_rx_queue,
so I think this is another tradeoff between the two sysfs approaches.

Best,

Mike
