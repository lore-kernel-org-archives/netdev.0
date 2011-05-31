From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] ftrace: tracepoint of net_dev_xmit sees freed skb and
 causes panic
Date: Tue, 31 May 2011 12:21:30 -0400
Message-ID: <1306858890.11899.32.camel@gandalf.stny.rr.com>
References: <4DE49D52.709@jp.fujitsu.com>
	 <1306854791.11899.30.camel@gandalf.stny.rr.com>
	 <20110531161115.GA3267@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, mingo@elte.hu, fweisbec@gmail.com,
	mathieu.desnoyers@efficios.com, tglx@linutronix.de,
	kosaki.motohiro@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110531161115.GA3267@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-31 at 12:11 -0400, Neil Horman wrote:
>  			skb_dst_drop(nskb);
> > >  
> > > +		skb_len = nskb->len;
> > >  		rc = ops->ndo_start_xmit(nskb, dev);
> > > -		trace_net_dev_xmit(nskb, rc);
> > > +		trace_net_dev_xmit(nskb, rc, dev, skb_len);
> > 
> > What if you just put the tracepoint before the call to
> > ops->ndo_start_xmit?
> > 
> Then you won't know the return code of ndo_start_xmit, which this tracepoint
> records.

Doh! Yeah, I see that now ;)

-- Steve
