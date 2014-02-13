From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] virtio-net: alloc big buffers also when guest can
	receive UFO
Date: Thu, 13 Feb 2014 13:40:59 +0800
Message-ID: <52FC5AEB.3090503@redhat.com>
References: <1392183808-16789-1-git-send-email-jasowang@redhat.com>
	<20140212115901.GC23006@redhat.com> <52FC35B5.6000900@redhat.com>
	<20140213051559.GB31352@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Sridhar Samudrala <sri@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140213051559.GB31352@redhat.com>
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

On 02/13/2014 01:15 PM, Michael S. Tsirkin wrote:
> On Thu, Feb 13, 2014 at 11:02:13AM +0800, Jason Wang wrote:
>> On 02/12/2014 07:59 PM, Michael S. Tsirkin wrote:
>>> On Wed, Feb 12, 2014 at 01:43:28PM +0800, Jason Wang wrote:
>>>>> We should alloc big buffers also when guest can receive UFO
>>>>> pakcets. Otherwise the big packets will be truncated when mergeable rx
>>>>> buffer is disabled.
>>> Not truncated, they will be dropped.
>>>
>> Why dropped? We enable the ufo on tap0 if VIRTIO_NET_F_GUEST_UFO is
>> negotiated. So skb was queued on the receive queue. But since the
>> receive buffer is small, it will be truncated during tun_put_user().
> Hypervisor shouldn't truncate packets silently - if it does
> it's a hypervisor bug. Passing malformed packets to guest is
> a bad idea.
>

Yes, but the commit log describes the current behaviour so it was ok?

Btw, dropping the packets silently is still not good. Virito needs a
method to report rx errors to guest.
