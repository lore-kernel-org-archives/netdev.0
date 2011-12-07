From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Wed, 07 Dec 2011 11:03:33 +0800
Message-ID: <4EDED785.80804@redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
	<4EDDB71F.9080908@redhat.com>
	<CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
	<4EDDECA9.8060808@redhat.com>
	<CAJSP0QXsLwvH5xYj6h0E_V4VLg6DuUc-GKXu9esEYzL2MFcFGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, bhutchings@solarflare.com
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAJSP0QXsLwvH5xYj6h0E_V4VLg6DuUc-GKXu9esEYzL2MFcFGw@mail.gmail.com>
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

On 12/06/2011 09:15 PM, Stefan Hajnoczi wrote:
> On Tue, Dec 6, 2011 at 10:21 AM, Jason Wang<jasowang@redhat.com>  wrote:
>> On 12/06/2011 05:18 PM, Stefan Hajnoczi wrote:
>>> On Tue, Dec 6, 2011 at 6:33 AM, Jason Wang<jasowang@redhat.com>    wrote:
>>>> On 12/05/2011 06:55 PM, Stefan Hajnoczi wrote:
>>>>> On Mon, Dec 5, 2011 at 8:59 AM, Jason Wang<jasowang@redhat.com>
>>>>>   wrote:
>>> The vcpus are just threads and may not be bound to physical CPUs, so
>>> what is the big picture here?  Is the guest even in the position to
>>> set the best queue mappings today?
>>
>> Not sure it could publish the best mapping but the idea is to make sure the
>> packets of a flow were handled by the same guest vcpu and may be the same
>> vhost thread in order to eliminate the packet reordering and lock
>> contention. But this assumption does not take the bouncing of vhost or vcpu
>> threads which would also affect the result.
> Okay, this is why I'd like to know what the big picture here is.  What
> solution are you proposing?  How are we going to have everything from
> guest application, guest kernel, host threads, and host NIC driver
> play along so we get the right steering up the entire stack.  I think
> there needs to be an answer to that before changing virtio-net to add
> any steering mechanism.

Consider the complexity of the host nic each with their own steering 
features,  this series make the first step with minimal effort to try to 
let guest driver and host tap/macvtap co-operate like what physical nic 
does. There may be other method, but performance numbers is also needed 
to give the answer.
>
> Stefan
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
