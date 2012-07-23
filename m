From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [net-next RFC V5 4/5] virtio_net: multiqueue support
Date: Mon, 23 Jul 2012 11:28:06 +0200
Message-ID: <500D1926.5020407@gmail.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-5-git-send-email-jasowang@redhat.com>
	<20120720134014.GD16550@redhat.com> <500A9A72.20507@gmail.com>
	<500CE72B.2040101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <500CE72B.2040101@redhat.com>
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

On 07/23/2012 07:54 AM, Jason Wang wrote:
> On 07/21/2012 08:02 PM, Sasha Levin wrote:
>> On 07/20/2012 03:40 PM, Michael S. Tsirkin wrote:
>>>> -    err = init_vqs(vi);
>>>>> +    if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>>>>> +        vi->has_cvq = true;
>>>>> +
>>> How about we disable multiqueue if there's no cvq?
>>> Will make logic a bit simpler, won't it?
>> multiqueues don't really depend on cvq. Does this added complexity really justifies adding an artificial limit?
>>
> 
> Yes, it does not depends on cvq. Cvq were just used to negotiate the number of queues a guest wishes to use which is really useful (at least for now). Since multiqueue can not out-perform for single queue in every kinds of workloads or benchmark, so we want to let guest driver use single queue by default even when multiqueue were enabled by management software and let use to enalbe it through ethtool. So user could not feel regression when it switch to use a multiqueue capable driver and backend.

Why would you limit it to a single vq if the user has specified a different number of vqs (>1) in the virtio-net device config?
