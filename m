From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next RFC V4 PATCH 0/4] Multiqueue virtio-net
Date: Mon, 25 Jun 2012 07:13:43 -0700
Message-ID: <4FE87217.5020208@intel.com>
References: <20120625090829.7263.65026.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120625100758.GB19169@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120625100758.GB19169@redhat.com>
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

On 6/25/2012 3:07 AM, Michael S. Tsirkin wrote:
> On Mon, Jun 25, 2012 at 05:16:48PM +0800, Jason Wang wrote:
>> Hello All:
>>
>> This series is an update version of multiqueue virtio-net driver based on
>> Krishna Kumar's work to let virtio-net use multiple rx/tx queues to do the
>> packets reception and transmission. Please review and comments.
>>
>> Test Environment:
>> - Intel(R) Xeon(R) CPU E5620 @ 2.40GHz, 8 cores 2 numa nodes
>> - Two directed connected 82599
>>
>> Test Summary:
>>
>> - Highlights: huge improvements on TCP_RR test
>> - Lowlights: regression on small packet transmission, higher cpu utilization
>>               than single queue, need further optimization
>
> Didn't review yet, reacting this this paragraph:
>
> To avoid regressions, it seems reasonable to make
> the device use a single queue by default for now.
> Add a way to switch multiqueue on/off using ethtool.
>
> This way guest admin can tune the device for the
> workload manually until we manage to imlement some
> self-tuning heuristics.
>

Ethtool already has this switch 'ethtool -L' can be
used to set the number tx/rx channels. So you would
likely just need to add a set_channels hook.

.John
