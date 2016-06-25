From: Andy Lutomirski <luto@amacapital.net>
Subject: DMA from stack in virtio_net and virtio_console
Date: Fri, 24 Jun 2016 18:45:50 -0700
Message-ID: <CALCETrXLQ7ajLaB4FENsg8XmRtjko10BqXR+KNcL7vuVeDrS8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	Amit Shah <amit.shah@redhat.com>,
	Linux Virtualization <virtualization@lists.linux-foundation.org>,
	Jason Wang <jasowang@redhat.com>, Alex Williamson <alex.williamson@hp.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

virtio_net does DMA on the stack when it calls sg_init_one in
virtio_set_queues, virtnet_vlan_rx_add_vid, and
virtnet_vlan_rx_kill_vid.  Michael, I think these are examples we
missed somehow when fixing these issues earlier on.

virtio_console does it here:

sg_init_one(sg, &cpkt, sizeof(cpkt));

This will cause problems on some architectures (Xen at the very least,
and it'll cause more subtle problems on other architectures if they
start using the DMA API), and it will blow up horribly with virtually
mapped stacks.

Could you fix these, please?

Thanks,
Andy
