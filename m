From: Ronen Hod <rhod@redhat.com>
Subject: Re: [PATCH net-next 4/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Wed, 13 Nov 2013 18:43:01 +0200
Message-ID: <5283AC15.8090706@redhat.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>	
	<1384294885-6444-4-git-send-email-mwdalton@google.com>	
	<52833C9B.7070908@redhat.com>
	<1384352348.28458.102.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1384352348.28458.102.camel@edumazet-glaptop2.roam.corp.google.com>
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

On 11/13/2013 04:19 PM, Eric Dumazet wrote:
> On Wed, 2013-11-13 at 10:47 +0200, Ronen Hod wrote:
>
>> I looked at how ewma works, and although it is computationally efficient,
>> and it does what it is supposed to do, initially (at the first samples) it is strongly
>> biased towards the value that was added at the first ewma_add.
>> I suggest that you print the values of ewma_add() and ewma_read(). If you are
>> happy with the results, then ignore my comments. If you are not, then I can
>> provide a version that does better for the first samples.
>> Unfortunately, it will be slightly less efficient.
> Value is clamped by (GOOD_PACKET_LEN, PAGE_SIZE - hdr_len)
>
> So initial value is conservative and not really used.

Hi Eric,

This initial value, that you do not really want to use, will slowly fade, but it
will still pretty much dominate the returned value for the first RECEIVE_AVG_WEIGHT(==64)
samples or so (most ewma implementations suffer from this bug).
Naturally, it doesn't matter much if you just keep it running forever.
However, if you will want to restart the learning process more often, which might make
sense upon changes, then the auto-tuning will be very sub-optimal.

Ronen.

> Thanks
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
