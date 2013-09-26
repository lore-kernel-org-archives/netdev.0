From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in ip_tunnel_xmit
Date: Thu, 26 Sep 2013 11:25:01 -0700
Message-ID: <CALnjE+ofaXQa3gsPPxqdWZeBxgML6M1vnC9mmc5dufwy0gJO-Q@mail.gmail.com>
References: <20130925055418.GV7660@secunet.com>
	<CALnjE+q1=EJGBBC9KC4_hcj2SPhSPQ3xNVt6RVFN2hZPFYM2TA@mail.gmail.com>
	<20130926082552.GB7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:58001 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753278Ab3IZSZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:25:03 -0400
Received: by mail-qe0-f51.google.com with SMTP id ne12so1098206qeb.10
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 11:25:01 -0700 (PDT)
In-Reply-To: <20130926082552.GB7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 26, 2013 at 1:25 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Wed, Sep 25, 2013 at 09:55:50AM -0700, Pravin Shelar wrote:
>> On Tue, Sep 24, 2013 at 10:54 PM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>> > We might extend the used aera of a skb beyond the total
>> > headroom when we install the ipip header. Fix this by
>> > calling skb_cow_head() unconditionally.
>> >
>> It is better to call skb_cow_head() from ipip_tunnel_xmit() as it is
>> consistent with gre.
>
> I think this would just move the bug from ipip to gre. ipgre_xmit()
> uses dev->needed_headroom which is based on the guessed output device
> in ip_tunnel_bind_dev(). If the device we get from the route lookup
> in ip_tunnel_xmit() is different from the guessed one and the resulting
> max_headroom is bigger than dev->needed_headroom, we run into that bug
> because skb_cow_head() will not be called with the updated
> dev->needed_headroom.
>
Thats why ip_tunnel_xmit() update dev->needed_headroom.
Just to be clear I was talking abt calling skb_cow_head with
dev->needed_headroom in ipip_xmit and leave ip_tunnel_xmit as it is.
So that most of cases we will not need to adjust headroom in ip_tunnel
xmit.
