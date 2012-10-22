From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Mon, 22 Oct 2012 14:20:36 +0400
Message-ID: <50851DF4.7050704@parallels.com>
References: <508123AC.5080208@parallels.com> <20121021.204351.350463326482954461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9042 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab2JVKUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 06:20:45 -0400
In-Reply-To: <20121021.204351.350463326482954461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2012 04:43 AM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Fri, 19 Oct 2012 13:55:56 +0400
> 
>> The SO_BINDTODEVICE option is the only SOL_SOCKET one that can be set, but
>> cannot be get via sockopt API. The only way we can find the device id a
>> socket is bound to is via sock-diag interface. But the diag works only on
>> hashed sockets, while the opt in question can be set for yet unhashed one.
>>
>> That said, in order to know what device a socket is bound to (we do want
>> to know this in checkpoint-restore project) I propose to make this option
>> getsockopt-able and report the respective device index.
>>
>> Another solution to the problem might be to teach the sock-diag reporting
>> info on unhashed sockets. Should I go this way instead?
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> Applied.  I can't believe we didn't support this when the feature
> was added.
> 
> I guess we figured that if the application made this setting, then
> it knows and doesn't need to query it.
> .

AFAIS such decision (application that configures something knows what it is) was
made for many things. The same is true at least for the SO_ATTACH_FILTER option
and for the shutdown syscall. Both add something to a socket that cannot be queried
back. And I'm now thinking which way for getting one would be better.

Thanks,
Pavel
