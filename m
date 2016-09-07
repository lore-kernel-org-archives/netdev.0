From: Saeed Mahameed via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit more
Date: Wed, 7 Sep 2016 17:40:21 +0300
Message-ID: <CALzJLG8TDJtyxigwLGvS+eKMLW-Wnv8sLcb7ou35tNJBbCZTnQ@mail.gmail.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<57D019B2.7070007@gmail.com>
Reply-To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <57D019B2.7070007-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On Wed, Sep 7, 2016 at 4:44 PM, John Fastabend via iovisor-dev
<iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org> wrote:
> On 16-09-07 05:42 AM, Saeed Mahameed wrote:
>> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
>>
>> Here we introduce a xmit more like mechanism that will queue up more
>> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
>>
>> Once RX napi budget is consumed and we exit napi RX loop, we will
>> flush (doorbell) all XDP looped packets in case there are such.
>>
>> XDP forward packet rate:
>>
>> Comparing XDP with and w/o xmit more (bulk transmit):
>>
>> Streams     XDP TX       XDP TX (xmit more)
>> ---------------------------------------------------
>> 1           4.90Mpps      7.50Mpps
>> 2           9.50Mpps      14.8Mpps
>> 4           16.5Mpps      25.1Mpps
>> 8           21.5Mpps      27.5Mpps*
>> 16          24.1Mpps      27.5Mpps*
>>
>
> Hi Saeed,
>
> How many cores are you using with these numbers? Just a single
> core? Or are streams being RSS'd across cores somehow.
>

Hi John,

Right I should have been more clear here, numbers of streams refers to
the active RSS cores.
We just manipulate the number of rings with ethtool -L to test this.

>> *It seems we hit a wall of 27.5Mpps, for 8 and 16 streams,
>> we will be working on the analysis and will publish the conclusions
>> later.
>>
>
> Thanks,
> John
> _______________________________________________
> iovisor-dev mailing list
> iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
> https://lists.iovisor.org/mailman/listinfo/iovisor-dev
