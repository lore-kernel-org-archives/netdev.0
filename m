From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost_net: clear msg.control for non-zerocopy case
	during tx
Date: Mon, 10 Jun 2013 14:32:16 -0700 (PDT)
Message-ID: <20130610.143216.418315514574898268.davem@davemloft.net>
References: <1370418046-11851-1-git-send-email-jasowang@redhat.com>
	<20130605090252.GA31830@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130605090252.GA31830@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 5 Jun 2013 12:02:52 +0300

> On Wed, Jun 05, 2013 at 03:40:46PM +0800, Jason Wang wrote:
>> When we decide not use zero-copy, msg.control should be set to NULL otherwise
>> macvtap/tap may set zerocopy callbacks which may decrease the kref of ubufs
>> wrongly.
>> 
>> Bug were introduced by commit cedb9bdce099206290a2bdd02ce47a7b253b6a84
>> (vhost-net: skip head management if no outstanding).
>> 
>> This solves the following warnings:
>> 
>> WARNING: at include/linux/kref.h:47 handle_tx+0x477/0x4b0 [vhost_net]()
>> Modules linked in: vhost_net macvtap macvlan tun nfsd exportfs bridge stp llc openvswitch kvm_amd kvm bnx2 megaraid_sas [last unloaded: tun]
>> CPU: 5 PID: 8670 Comm: vhost-8668 Not tainted 3.10.0-rc2+ #1566
>> Hardware name: Dell Inc. PowerEdge R715/00XHKG, BIOS 1.5.2 04/19/2011
>> ffffffffa0198323 ffff88007c9ebd08 ffffffff81796b73 ffff88007c9ebd48
>> ffffffff8103d66b 000000007b773e20 ffff8800779f0000 ffff8800779f43f0
>> ffff8800779f8418 000000000000015c 0000000000000062 ffff88007c9ebd58
>> Call Trace:
>> [<ffffffff81796b73>] dump_stack+0x19/0x1e
>> [<ffffffff8103d66b>] warn_slowpath_common+0x6b/0xa0
>> [<ffffffff8103d6b5>] warn_slowpath_null+0x15/0x20
>> [<ffffffffa0197627>] handle_tx+0x477/0x4b0 [vhost_net]
>> [<ffffffffa0197690>] handle_tx_kick+0x10/0x20 [vhost_net]
>> [<ffffffffa019541e>] vhost_worker+0xfe/0x1a0 [vhost_net]
>> [<ffffffffa0195320>] ? vhost_attach_cgroups_work+0x30/0x30 [vhost_net]
>> [<ffffffffa0195320>] ? vhost_attach_cgroups_work+0x30/0x30 [vhost_net]
>> [<ffffffff81061f46>] kthread+0xc6/0xd0
>> [<ffffffff81061e80>] ? kthread_freezable_should_stop+0x70/0x70
>> [<ffffffff817a1aec>] ret_from_fork+0x7c/0xb0
>> [<ffffffff81061e80>] ? kthread_freezable_should_stop+0x70/0x70
>> 
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Good catch.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> This needs to go into stable as well.

Applied and queued up for -stable.
