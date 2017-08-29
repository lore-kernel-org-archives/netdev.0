From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
	path if no tx napi
Date: Tue, 29 Aug 2017 18:55:32 -0400
Message-ID: <CAF=yD-LzBowzRNREFCF4fGoQ=Z4hnJR=eTXoAfJZ_mOe-ZznrA@mail.gmail.com>
References: <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
	<20170824160748-mutt-send-email-mst@kernel.org>
	<CAF=yD-+9Ah8pC9i2w3Ad3WnhQit7Yo479pMrToty7priL6BFLw@mail.gmail.com>
	<20170824234551-mutt-send-email-mst@kernel.org>
	<CAF=yD-+1wheMmC+HFKe_B_ULO0Mmh6HMSEbYY5D-HgqxVJee6A@mail.gmail.com>
	<20170826022744-mutt-send-email-mst@kernel.org>
	<CAF=yD-Lre0NATUVH8p0zS=G5CiY=WfKSefLmOZw940jZFgECgQ@mail.gmail.com>
	<CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com>
	<20170829224136-mutt-send-email-mst@kernel.org>
	<CAF=yD-L5MG5RCZzT8EZ0coFiuQLp-2UQN0zzQefVnEd7rMQbyw@mail.gmail.com>
	<20170829233920-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	Koichiro Den <den@klaipeden.com>, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170829233920-mutt-send-email-mst@kernel.org>
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

On Tue, Aug 29, 2017 at 4:40 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Aug 29, 2017 at 03:53:08PM -0400, Willem de Bruijn wrote:
>> On Tue, Aug 29, 2017 at 3:42 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> > On Tue, Aug 29, 2017 at 03:35:38PM -0400, Willem de Bruijn wrote:
>> >> By the way, I have had an unrelated patch outstanding for a while
>> >> to have virtio-net support the VIRTIO_CONFIG_S_NEEDS_RESET
>> >> command. Will send that as RFC.
>> >
>> > Oh nice.
>>
>> Great :)
>>
>> > One needs to be careful about locking there which is why
>> > no devices support that yet.
>>
>> I originally wrote it based on the virtnet_reset function introduced
>> for xdp. Calling this from virtnet_config_changed_work is non trivial,
>> as virtnet_freeze_down waits until no config worker is running.
>>
>> Otherwise, I could not find any constraints on when freeze may be
>> called, and it largely follows the same path. I hope I didn't miss anything.
>
> The issue is that on freeze processes are not running so we
> generally know no new packets will arrive (might be wrong
> for bridging, then it's a bug). On device error you must
> prevent new skbs from coming in, etc.

Thanks a lot for the quick review. I had indeed not yet figured out
which invariants freeze can depend on that are not universal. Same
for the virtnet_reset call from the .ndo_xdp. Will need to take a much
better look at that.
