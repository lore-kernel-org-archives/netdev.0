From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2] xen-netback: Rework rx_work_todo
Date: Tue, 4 Feb 2014 19:55:42 +0000
Message-ID: <52F145BE.3090606@citrix.com>
References: <1389805867-22409-1-git-send-email-zoltan.kiss@citrix.com> <20140120163814.GE11681@zion.uk.xensource.com> <52F13D24.5090405@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>, David Miller <davem@davemloft.net>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52F13D24.5090405@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/02/14 19:19, Zoltan Kiss wrote:
> On 20/01/14 16:38, Wei Liu wrote:
>> On Wed, Jan 15, 2014 at 05:11:07PM +0000, Zoltan Kiss wrote:
>>> The recent patch to fix receive side flow control (11b57f) solved the
>>> spinning
>>> thread problem, however caused an another one. The receive side can
>>> stall, if:
>>> - [THREAD] xenvif_rx_action sets rx_queue_stopped to true
>>> - [INTERRUPT] interrupt happens, and sets rx_event to true
>>> - [THREAD] then xenvif_kthread sets rx_event to false
>>> - [THREAD] rx_work_todo doesn't return true anymore
>>>
>>> Also, if interrupt sent but there is still no room in the ring, it
>>> take quite a
>>> long time until xenvif_rx_action realize it. This patch ditch that
>>> two variable,
>>> and rework rx_work_todo. If the thread finds it can't fit more skb's
>>> into the
>>> ring, it saves the last slot estimation into rx_last_skb_slots,
>>> otherwise it's
>>> kept as 0. Then rx_work_todo will check if:
>>> - there is something to send to the ring (like before)
>>> - there is space for the topmost packet in the queue
>>>
>>> I think that's more natural and optimal thing to test than two bool
>>> which are
>>> set somewhere else.
>>>
>>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>>
>> Sorry for the delay.
>>
>> Paul, thanks for reviewing.
>>
>> Acked-by: Wei Liu <wei.liu2@citrix.com>
>
> Hi,
>
> This patch haven't made it to net-next yet, maybe because the subject
> doesn't suggest that this is a bugfix. I suggest to apply it as soon as
> possible, otherwise netback will be quite broken.

I've reposted it with clearer subject, sorry for being too vague

Zoli
