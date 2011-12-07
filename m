From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 0/5] Series short description
Date: Wed, 07 Dec 2011 19:31:14 +0800
Message-ID: <4EDF4E82.7050201@redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<87ty5cj0sw.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, bhutchings@solarflare.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87ty5cj0sw.fsf@rustcorp.com.au>
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

On 12/07/2011 03:30 PM, Rusty Russell wrote:
> On Mon, 05 Dec 2011 16:58:37 +0800, Jason Wang<jasowang@redhat.com>  wrote:
>> multiple queue virtio-net: flow steering through host/guest cooperation
>>
>> Hello all:
>>
>> This is a rough series adds the guest/host cooperation of flow
>> steering support based on Krish Kumar's multiple queue virtio-net
>> driver patch 3/3 (http://lwn.net/Articles/467283/).
> Is there a real (physical) device which does this kind of thing?  How do
> they do it?  Can we copy them?
>
> Cheers,
> Rusty.
As far as I see, ixgbe and sfc have similar but much more sophisticated 
mechanism.

The idea was originally suggested by Ben and it was just borrowed form 
those real physical nic cards who can dispatch packets based on their 
hash. All of theses cards can filter the flow based on the hash of 
L2/L3/L4 header and the stack would tell the card which queue should 
this flow goes.

So in host, a simple hash to queue table were introduced in tap/macvtap 
and in guest, the guest driver would tell the desired queue of a flow 
through changing this table.
