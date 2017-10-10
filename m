From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next 2/4] net: sched: introduce per-egress action
 device callbacks
Date: Tue, 10 Oct 2017 15:12:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD008F06E@AcuExch.aculab.com>
References: <20171010073016.3682-1-jiri@resnulli.us>
 <20171010073016.3682-3-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6DD008ED67@AcuExch.aculab.com>
 <20171010143152.GG2033@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "matanb@mellanox.com" <matanb@mellanox.com>,
        "leonro@mellanox.com" <leonro@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>
To: 'Jiri Pirko' <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:52409 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932107AbdJJPMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 11:12:37 -0400
In-Reply-To: <20171010143152.GG2033@nanopsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
> Sent: 10 October 2017 15:32
> To: David Laight
> Cc: netdev@vger.kernel.org; davem@davemloft.net; jhs@mojatatu.com; xiyou.wangcong@gmail.com;
> saeedm@mellanox.com; matanb@mellanox.com; leonro@mellanox.com; mlxsw@mellanox.com
> Subject: Re: [patch net-next 2/4] net: sched: introduce per-egress action device callbacks
> 
> Tue, Oct 10, 2017 at 03:31:59PM CEST, David.Laight@ACULAB.COM wrote:
> >From: Jiri Pirko
> >> Sent: 10 October 2017 08:30
> >> Introduce infrastructure that allows drivers to register callbacks that
> >> are called whenever tc would offload inserted rule and specified device
> >> acts as tc action egress device.
> >
> >How does a driver safely unregister a callback?
> >(to avoid a race with the callback being called.)
> >
> >Usually this requires a callback in the context that makes the
> >notification callbacks indicating that no more such callbacks
> >will be made.
> 
> rtnl is your answer. It is being held during register/unregister/cb

Do you mean 'acquired during register/unregister' and 'held across the
callback' ?

So the unregister sleeps (or spins?) until any callbacks complete?
So the driver mustn't hold any locks (etc) across the unregister that
it acquires in the callback.
That ought to be noted somewhere.

	David
