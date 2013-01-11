From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH 0/2] make mac programming for virtio net more robust
Date: Fri, 11 Jan 2013 06:52:51 -0800
Message-ID: <50F02743.2080404@intel.com>
References: <1357829141-25455-1-git-send-email-akong@redhat.com>
	<20130110152829.GG30731@redhat.com>
	<87fw281mr8.fsf@rustcorp.com.au>
	<20130111074624.GB13315@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, qemu-devel@nongnu.org,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130111074624.GB13315@redhat.com>
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

On 1/10/2013 11:46 PM, Michael S. Tsirkin wrote:
> On Fri, Jan 11, 2013 at 12:53:07PM +1030, Rusty Russell wrote:
>> "Michael S. Tsirkin" <mst@redhat.com> writes:
>>
>>> On Thu, Jan 10, 2013 at 10:45:39PM +0800, akong@redhat.com wrote:
>>>> From: Amos Kong <akong@redhat.com>
>>>>
>>>> Currenly mac is programmed byte by byte. This means that we
>>>> have an intermediate step where mac is wrong.
>>>>
>>>> Second patch introduced a new vq control command to set mac
>>>> address in one time.
>>>
>>> As you mention we could alternatively do it without
>>> new commands, simply add a feature bit that says that MACs are
>>> in the mac table.
>>> This would be a much bigger patch, and I'm fine with either way.
>>> Rusty what do you think?
>>
>> Hmm, mac filtering and "my mac address" are not quite the same thing.  I
>> don't know if it matters for anyone: does it?
>> The mac address is abused
>> for things like identifying machines, etc.
>
> I don't know either. I think net core differentiates between mac and
> uc_list because linux has to know which mac to use when building
> up packets, so at some level, I agree it might be useful to identify the
> machine.
>
> BTW netdev/davem should have been copied on this, Amos I think it's a
> good idea to remember to do it next time you post.
>
>>
>> If we keep it as a separate concept, Amos' patch seems to make sense.
>
> Yes. It also keeps the patch small, I just thought I'd mention the
> option.
>
>>
>> Cheers,
>> Rusty.
>

Don't have the entire context here but if you implement the
ndo_fdb_dump() probably hooking it up to ndo_dflt_fdb_dump() you could
use the 'bridge' tool dump the uc_list.

Then use ndo_fdb_add() and ndo_fdb_del() to add and remove entries
from the uc_list. We do this today in macvlan and the ixgbe driver when
it is in SR-IOV mode and the embedded switch needs to be programmed.

fdb is "forwarding database" its a bit different then mac filtering
in that its telling the "switch" how to forward mac addresses, in
ixgbe and macvlan at least we have been overloading it a bit to also
stop filtering the mac address. I think this makes sense if you setup
forwarding to a port it doesn't make much sense to then drop them.

Maybe its not entirely applicable here just thought I would mention it.

Thanks,
John
