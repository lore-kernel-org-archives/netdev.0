From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Tue, 07 Jan 2014 11:17:06 +0800
Message-ID: <52CB71B2.4070005@redhat.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com> <20140106.154740.590358835696689785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, john.r.fastabend@intel.com, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140106.154740.590358835696689785.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/07/2014 04:47 AM, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Mon,  6 Jan 2014 11:21:06 +0800
>
>> L2 fowarding offload will bypass the rx handler of real device. This will make
>> the packet could not be forwarded to macvtap device. Another problem is the
>> dev_hard_start_xmit() called for macvtap does not have any synchronization.
>>
>> Fix this by forbidding L2 forwarding for macvtap.
>>
>> Cc: John Fastabend <john.r.fastabend@intel.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> I think I agree with Neil that the rx_handler change might be the best
> way to fix this.  That change seems to have a lot of nice unintended
> side effects, no?

Not all sides effects are nice.

One obvious issue is it disables the multiqueue macvtap transmission,
since all queues will contend on a single qdisc lock of macvlan. And
even more, multiqueue macvtap support creating and destroying a queue on
demand which is not supported by L2 forwarding offload.

So L2 forwarding offload needs more fixes to let the multiqueue macvtap
works. Currently, we really need this patch to make sure macvtap works
as expected.
