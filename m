From: Baruch Even <baruch@ev-en.org>
Subject: Re: netif_rx packet dumping
Date: Thu, 03 Mar 2005 23:48:12 +0000
Message-ID: <4227A23C.5050300@ev-en.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>	<20050303125556.6850cfe5.davem@davemloft.net>	<1109884688.1090.282.camel@jzny.localdomain>	<20050303132143.7eef517c@dxpl.pdx.osdl.net>	<1109885065.1098.285.camel@jzny.localdomain>	<20050303133237.5d64578f.davem@davemloft.net>	<20050303135416.0d6e7708@dxpl.pdx.osdl.net>	<Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu>	<1109888811.1092.352.camel@jzny.localdomain> <20050303151606.3587394f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, John Heffner <jheffner@psc.edu>,
        "David S. Miller" <davem@davemloft.net>, rhee@eos.ncsu.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050303151606.3587394f@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On 03 Mar 2005 17:26:51 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
>>On Thu, 2005-03-03 at 17:02, John Heffner wrote:
>>
>>>On Thu, 3 Mar 2005, Stephen Hemminger wrote:
>>>
>>>>Maybe a simple Random Exponential Drop (RED) would be more friendly.
>>>
>>>That would probably not be appropriate.  This queue is only for absorbing
>>>micro-scale bursts.  It should not hold any data in steady state like a
>>>router queue can.  The receive window can handle the macro scale flow
>>>control.
>>
>>recall this is a queue that is potentially shared by many many flows
>>from potentially many many interfaces i.e it deals with many many
>>micro-scale bursts.
>>Clearly, the best approach is to have lots and lots of memmory and to
>>make that queue real huge so it can cope with all of them all the time.
>>We dont have that luxury - If you restrict the queue size, you will have
>>to drop packets... Which ones?
>>Probably simplest solution is to leave it as is right now and just
>>adjust the contraints based on your system memmory etc.
> 
> Another alternative would be some form of adaptive threshold,
> something like adaptive drop tail described in this paper.
> http://www.ee.cityu.edu.hk/~gchen/pdf/ITC18.pdf

What is the purpose of all of these schemes?

The queue is there to handle short bursts of packets when the network 
stack cannot handle it. The bad behaviour was the throttling of the 
queue, the smart schemes are not going to make it that much better if 
the hardware/software can't keep up.

Even adding more memory to the queue is not going to make a big 
difference, it will just delay the inevitable end and add some more 
queueing latency to the connections.

Baruch
