From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv4] virtio-spec: virtio network device multiqueue support
Date: Wed, 12 Sep 2012 15:19:11 +0930
Message-ID: <87har3dc4o.fsf@rustcorp.com.au>
References: <20120909130308.GA3471@redhat.com> <878vcifwxi.fsf@rustcorp.com.au>
	<20120910061629.GC16819@redhat.com>
	<20120910062738.GA17331@redhat.com>
	<20120910063346.GA17338@redhat.com> <504DC831.1000709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, rick.jones2@hp.com,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, pbonzini@redhat.com,
	Tom Herbert <therbert@google.com>
To: Jason Wang <jasowang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <504DC831.1000709@redhat.com>
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

Jason Wang <jasowang@redhat.com> writes:
> On 09/10/2012 02:33 PM, Michael S. Tsirkin wrote:
>> A final addition: what you suggest above would be
>> "TX follows RX", right?

BTW, yes.  But it's a weird way to express what the nic is doing.

>> It is in anticipation of something like that, that I made
>> steering programming so generic.

>> I think TX follows RX is more immediately useful for reasons above
>> but we can add both to spec and let drivers and devices
>> decide what they want to support.

You mean "RX follows TX"?  ie. accelerated RFS.  I agree.

Perhaps Tom can explain how we avoid out-of-order receive for the
accelerated RFS case?  It's not clear to me, but we need to be able to
do that for virtio-net if it implements accelerated RFS.

> AFAIK, ixgbe does "rx follows tx". The only differences between ixgbe 
> and virtio-net is that ixgbe driver programs the flow director during 
> packet transmission but we suggest to do it silently in the device for 
> simplicity.

Implying the receive queue by xmit will be slightly laggy.  Don't know
if that's a problem.

Cheers,
Rusty.
