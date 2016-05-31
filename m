From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v5 0/2] skb_array: array based FIFO for skbs
Date: Tue, 31 May 2016 10:29:23 +0800
Message-ID: <574CF703.9030200@redhat.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
 <574C0F05.1040500@redhat.com> <20160530183455-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160530183455-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016=E5=B9=B405=E6=9C=8830=E6=97=A5 23:37, Michael S. Tsirkin wrote:
> On Mon, May 30, 2016 at 05:59:33PM +0800, Jason Wang wrote:
>>
>> On 2016=E5=B9=B405=E6=9C=8823=E6=97=A5 18:43, Michael S. Tsirkin wro=
te:
>>> This is in response to the proposal by Jason to make tun
>>> rx packet queue lockless using a circular buffer.
>>> My testing seems to show that at least for the common usecase
>>> in networking, which isn't lockless, circular buffer
>>> with indices does not perform that well, because
>>> each index access causes a cache line to bounce between
>>> CPUs, and index access causes stalls due to the dependency.
>> I change tun to use skb array, looks like it can give about 5% more =
faster
>> than skb ring.
> OK and skb ring is 9% faster than the linked list, so together
> this is a 14% speedup?

Right.

>
>> And we usually don't need touch bhs during consume and produce (e.g =
for the
>> case of tun).
>>
>> Thanks
> Maybe I'll drop it in v6 then ...
> Could you post the full tun patchset please?
>

Since it needs no bh versions of produce/consume, maybe you can post v6=
=20
first, then I can post the tun patches?
