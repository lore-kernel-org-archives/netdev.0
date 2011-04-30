From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH 0/2] Multiqueue support for
	qemu(virtio-net)
Date: Sat, 30 Apr 2011 22:55:26 +0800
Message-ID: <19900.8926.555478.30391@gargle.gargle.HOWL>
References: <20110420082706.32157.59668.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	<OF7CC46028.9A206852-ON65257878.00307271-65257878.00308D38@in.ibm.com>
	<19887.42381.34145.956833@gargle.gargle.HOWL>
	<4DBB1B25.1020300@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	rusty@rustcorp.com.au, qemu-devel@nongnu.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <4DBB1B25.1020300@codemonkey.ws>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Anthony Liguori writes:
 > On 04/20/2011 10:33 PM, Jason Wang wrote:
 > > Krishna Kumar2 writes:
 > >   >  Thanks Jason!
 > >   >
 > >   >  So I can use my virtio-net guest driver and test with this patch?
 > >   >  Please provide the script you use to start MQ guest.
 > >   >
 > >
 > > Yes and thanks. Following is a simple script may help you start macvtap mq
 > > guest.
 > >
 > > qemu_path=./qemu-system-x86_64
 > > img_path=/home/kvm_autotest_root/images/mq.qcow2
 > > vtap_dev=/dev/tap104
 > > mac=96:88:12:1C:27:83
 > > smp=2
 > > mq=4
 > >
 > > for i in `seq $mq`
 > > do
 > >      vtap+=" -netdev tap,id=hn$i,fd=$((i+100)) $((i+100))<>$vtap_dev"
 > 
 > So you are basically dup()'ing the tap device.
 > 
 > Does this actually improve performance at all?
 > 

The script maybe not clear. It works only for macvtap (tap does not have
multiqueue support and I plan to add it). A macvtap device needs to be created
first by ip command.

The multiqueue was achieved by opening the macvtap device many times. Each time
 the user open to macvtap device, a new queue (sock) was created. Then macvtap
 device then can forward the packets to different sock/fd based on their RX
 queue of physical nics. So the fd could be used to registered as a backend for
 vhost/qemu.

Performance improvement is expected when using smp guest with mq virtio-net and
mq nic.

 > Regards,
 > 
 > Anthony Liguori
 > 


-- 
Jason Wang
