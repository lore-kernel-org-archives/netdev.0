From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] virtio-net: coalesce rx frags when possible
	during rx
Date: Fri, 01 Nov 2013 13:37:02 +0800
Message-ID: <52733DFE.7090704@redhat.com>
References: <1383215313-23651-1-git-send-email-jasowang@redhat.com>
	<1383215313-23651-2-git-send-email-jasowang@redhat.com>
	<87iowcc1id.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>, davem@davemloft.net,
	edumazet@google.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mst@redhat.com, mwdalton@google.com,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87iowcc1id.fsf@rustcorp.com.au>
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

On 11/01/2013 10:13 AM, Rusty Russell wrote:
> Jason Wang <jasowang@redhat.com> writes:
>> Commit 2613af0ed18a11d5c566a81f9a6510b73180660a (virtio_net: migrate mergeable
>> rx buffers to page frag allocators) try to increase the payload/truesize for
>> MTU-sized traffic. But this will introduce the extra overhead for GSO packets
>> received because of the frag list. This commit tries to reduce this issue by
>> coalesce the possible rx frags when possible during rx. Test result shows the
>> about 15% improvement on full size GSO packet receiving (and even better than
>> commit 2613af0ed18a11d5c566a81f9a6510b73180660a).
> I don't know about the other users of skb_add_rx_frag, but should
> this coalesce-if-possible code be built into that?

There're several other users without the possibility check. And Eric
point out in do_tcp_sendpages() skb_add_rx_frag() and skb_can_coalesce()
were used separatedly which can allows us to do some other things in the
middle. So it was ok here.
>
> Thanks,
> Rusty.
