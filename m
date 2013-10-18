From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net V2 1/2] virtio-net: don't respond to cpu hotplug
	notifier if we're not ready
Date: Fri, 18 Oct 2013 11:30:15 +1030
Message-ID: <87d2n3s89s.fsf@rustcorp.com.au>
References: <1381807139-3450-1-git-send-email-jasowang@redhat.com>
	<8738o0aj9u.fsf@rustcorp.com.au>
	<20131017050710.GA12141@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131017050710.GA12141@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Thu, Oct 17, 2013 at 09:57:41AM +1030, Rusty Russell wrote:
>> Jason Wang <jasowang@redhat.com> writes:
>> > We're trying to re-configure the affinity unconditionally in cpu hotplug
>> > callback. This may lead the issue during resuming from s3/s4 since
>> >
>> > - virt queues haven't been allocated at that time.
>> > - it's unnecessary since thaw method will re-configure the affinity.
>> >
>> > Fix this issue by checking the config_enable and do nothing is we're not ready.
>> >
>> > The bug were introduced by commit 8de4b2f3ae90c8fc0f17eeaab87d5a951b66ee17
>> > (virtio-net: reset virtqueue affinity when doing cpu hotplug).
>> >
>> > Cc: Rusty Russell <rusty@rustcorp.com.au>
>> > Cc: Michael S. Tsirkin <mst@redhat.com>
>> > Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
>> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
>> > Reviewed-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
>> > ---
>> > The patch is need for 3.8 and above.
>> 
>> Please put 'CC: stable@kernel.org # 3.8+' in the commit.
>
> Not if this is going in through the net tree.

WTF?  Wow, there really *is* an FAQ: https://lwn.net/Articles/561669/

DaveM is the best maintainer I've ever known, but I abhor the idea that
every subsystem has its own incompatible variant on workflow and style.

Asking people to express 'CC: stable' in words is error-prone; if Dave
wants to filter it, he's quite capable.

Rusty.
