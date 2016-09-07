From: Tom Herbert via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf
	programs support
Date: Wed, 7 Sep 2016 09:54:10 -0700
Message-ID: <CALx6S35b_MZXiGR-b1SB+VNifPHDfQNDZdz-6vk0t3bKNwen+w@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-9-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMhh=fu+mrCGAjv1PDdGn9GPLJv9MssMzwzvppoqZUY01A@mail.gmail.com>
	<CALzJLG8_F28kQOPqTTLJRMsf9BOQvm3K2hAraCzabnXV4yKUgg@mail.gmail.com>
Reply-To: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <CALzJLG8_F28kQOPqTTLJRMsf9BOQvm3K2hAraCzabnXV4yKUgg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 7, 2016 at 7:48 AM, Saeed Mahameed
<saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:
> On Wed, Sep 7, 2016 at 4:32 PM, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On Wed, Sep 7, 2016 at 3:42 PM, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>>
>>> Packet rate performance testing was done with pktgen 64B packets and on
>>> TX side and, TC drop action on RX side compared to XDP fast drop.
>>>
>>> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
>>>
>>> Comparison is done between:
>>>         1. Baseline, Before this patch with TC drop action
>>>         2. This patch with TC drop action
>>>         3. This patch with XDP RX fast drop
>>>
>>> Streams    Baseline(TC drop)    TC drop    XDP fast Drop
>>> --------------------------------------------------------------
>>> 1           5.51Mpps            5.14Mpps     13.5Mpps
>>> 2           11.5Mpps            10.0Mpps     25.1Mpps
>>> 4           16.3Mpps            17.2Mpps     35.4Mpps
>>> 8           29.6Mpps            28.2Mpps     45.8Mpps*
>>> 16          34.0Mpps            30.1Mpps     45.8Mpps*
>>
>> Rana, Guys, congrat!!
>>
>> When you say X streams, does each stream mapped by RSS to different RX ring?
>> or we're on the same RX ring for all rows of the above table?
>
> Yes, I will make this more clear in the actual submission,
> Here we are talking about different RSS core rings.
>
>>
>> In the CX3 work, we had X sender "streams" that all mapped to the same RX ring,
>> I don't think we went beyond one RX ring.
>
> Here we did, the first row is what you are describing the other rows
> are the same test
> with increasing the number of the RSS receiving cores, The xmit side is sending
> as many streams as possible to be as much uniformly spread as possible
> across the
> different RSS cores on the receiver.
>
Hi Saeed,

Please report CPU utilization also. The expectation is that
performance should scale linearly with increasing number of CPUs (i.e.
pps/CPU_utilization should be constant).

Tom

>>
>> Here, I guess you want to 1st get an initial max for N pktgen TX
>> threads all sending
>> the same stream so you land on single RX ring, and then move to M * N pktgen TX
>> threads to max that further.
>>
>> I don't see how the current Linux stack would be able to happily drive 34M PPS
>> (== allocate SKB, etc, you know...) on a single CPU, Jesper?
>>
>> Or.
