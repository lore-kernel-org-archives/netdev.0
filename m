From: jamal <hadi@cyberus.ca>
Subject: Re: netif_rx packet dumping
Date: 03 Mar 2005 17:01:37 -0500
Message-ID: <1109887297.1098.329.camel@jzny.localdomain>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	 <20050303125556.6850cfe5.davem@davemloft.net>
	 <1109884688.1090.282.camel@jzny.localdomain>
	 <20050303132143.7eef517c@dxpl.pdx.osdl.net>
	 <1109885065.1098.285.camel@jzny.localdomain>
	 <20050303133237.5d64578f.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, rhee@eos.ncsu.edu, jheffner@psc.edu,
        Yee-Ting.Li@nuim.ie, baruch@ev-en.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050303133237.5d64578f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-03 at 16:32, David S. Miller wrote:
> On 03 Mar 2005 16:24:25 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > Ok, this does sound more reasonable. Out of curiosity, are packets being
> > dropped at the socket queue? Why is "dump till empty" behaviour screwing
> > over TCP.
> 
> Because it does the same thing tail-drop in routers do.
> It makes everything back off a lot and go into slow start.
> If we'd just drop 1 packet per flow or something like that
> (so it could be fixed with a quick fast retransmit), TCP
> would avoid regressing into slow start.
>
> You say "use a NAPI driver", but netif_rx() _IS_ a NAPI driver.
> process_backlog() adheres to quotas and every other stabilizing
> effect NAPI drivers use, the only missing part is the RX interrupt
> disabling.
> 

Thats true; but it's the RX interrupt disabling that worries me.
And the fact that memory is finite.

Let me throw some worst case scenarios:
In the (ahem) "old" days when 100Mbps was hip, 148kpps (translate to
about 1-2 interupts per packet) you pretty much fill that queue pretty
quickly before it is processed. You could say the pentium-2 class used
then was "slow" - but it is probably same compute capacity as most of
the embedded systems out there today. On Gige we are talking about
queueing upto 100K packets per ethx.
I realize i am using unreasonable worst case but it becomes eventually a
choice of when to stop accepting packets in order to maintain sanity.

cheers,
jamal
