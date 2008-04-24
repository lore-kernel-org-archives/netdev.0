From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [patch 37/37] LTTng instrumentation net
Date: Thu, 24 Apr 2008 20:30:56 +0400
Message-ID: <4810B5C0.1080501@openvz.org>
References: <20080424150324.802695381@polymtl.ca> <20080424151408.991424268@polymtl.ca> <4810ACB4.501@openvz.org> <20080424161337.GA22874@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51660 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753585AbYDXQeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 12:34:05 -0400
In-Reply-To: <20080424161337.GA22874@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathieu Desnoyers wrote:
> * Pavel Emelyanov (xemul@openvz.org) wrote:
>> Mathieu Desnoyers wrote:
>>> Network core events.
>>>
>>> Added markers :
>>>
>>> net_del_ifa_ipv4
>>> net_dev_receive
>>> net_dev_xmit
>>> net_insert_ifa_ipv4
>>> net_socket_call
>>> net_socket_create
>>> net_socket_recvmsg
>>> net_socket_sendmsg
>> Network "core" events are not limited with the above calls.
>>
> 
> True. This is by no mean an exhaustive list of network events. It just
> happens to be the ones which has been useful to LTT/LTTng users for the
> past ~10 years.

Do you mean, that we'll have these debris all over the networking code some day?

>> Besides, real "core" events already sent notifications about themselves.
>> Why do we need additional hooks?
>>
> 
> I doubt the current notification hooks have a performance impact as
> small as the proposed markers. Which notification mechanism do you refer
> to ? It could be interesting to put markers in there instead.

E.g. call_netdevice_notifiers and co. 
And they have nothing to do with performance, since configuration code is 
not supposed to have a rocket speed.

> The goal behind this is to feed information to a general purpose tracer
> like lttng, a scripting mechanism like systemtap or a special-purpose
> tracer like ftrace.
> 
> I think that the most important instrumentation in this patchset is the
> xmit/recv of a packet at the device level. The net_socket_*
> instrumentation could eventually be replaced by an architecture specfic
> system call parameters instrumentation.

I will not argue about the value of such hooks in xmit/recv paths, but
as far as the net_socket_xxx is concerned - there is already the
* ptrace
* security
* kprobes
way to screw the normal code flow up in these places.

> Mathieu
> 
>>> Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
>>> CC: netdev@vger.kernel.org
>>> ---
>>>  net/core/dev.c     |    6 ++++++
>>>  net/ipv4/devinet.c |    6 ++++++
>>>  net/socket.c       |   19 +++++++++++++++++++
>>>  3 files changed, 31 insertions(+)
> 

