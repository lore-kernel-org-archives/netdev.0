From: Dor Laor <dlaor@redhat.com>
Subject: Re: [PATCH 2/3] virtio: indirect ring
	entries	(VIRTIO_RING_F_INDIRECT_DESC)
Date: Mon, 27 Apr 2009 10:43:53 +0300
Message-ID: <49F56239.9010509@redhat.com>
References: <1229620222-22216-1-git-send-email-markmc@redhat.com>	<1229620222-22216-2-git-send-email-markmc@redhat.com>	<1229620222-22216-3-git-send-email-markmc@redhat.com>
	<1240318745.443.42.camel@blaa>
Reply-To: dlaor@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dor Laor <dor@redhat.com>,
        Avi Kivity <avi@redhat.com>, virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1240318745.443.42.camel@blaa>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Mark McLoughlin wrote:
> Hi Rusty,
>
> On Thu, 2008-12-18 at 17:10 +0000, Mark McLoughlin wrote:
>   
>> Add a new feature flag for indirect ring entries. These are ring
>> entries which point to a table of buffer descriptors.
>>
>> The idea here is to increase the ring capacity by allowing a larger
>> effective ring size whereby the ring size dictates the number of
>> requests that may be outstanding, rather than the size of those
>> requests.
>>
>> This should be most effective in the case of block I/O where we can
>> potentially benefit by concurrently dispatching a large number of
>> large requests. Even in the simple case of single segment block
>> requests, this results in a threefold increase in ring capacity.
>>     
>
> Apparently, this would also be useful for the windows virtio-net
> drivers.
>
> Dor can explain further, but apparently Windows has been observed
> passing the driver a packet with >256 fragments when using TSO.
>
> With a ring size of 256, the guest can either drop the packet or copy it
> into a single buffer. We'd much rather if we could use an indirect ring
> entry to pass this number of fragments without copying.
>   
Correct. This is what we do in Windows today.
The problem arises when using sending lots of small packets
from the win guest and TSO. Windows prepare very big scatter gather
list, bigger than the ring size (270 fragments).
Having indirect ring entries is good both for this and also for block 
io, as described
above.

Cheers,
Dor
> For reference the original patch was here:
>
>   http://lkml.org/lkml/2008/12/18/212
>
> Cheers,
> Mark.
>
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/virtualization
>   
