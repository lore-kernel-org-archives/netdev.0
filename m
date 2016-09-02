From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Fri, 2 Sep 2016 10:35:34 +0200
Message-ID: <20160902103534.670b8f6a@redhat.com>
References: <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831214043.2f44cf08@redhat.com>
        <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831235116.33b1946b@redhat.com>
        <20160901130231.58355405@redhat.com>
        <20160901115356.GT10153@twins.programming.kicks-ass.net>
        <20160901142925.63a5031b@redhat.com>
        <20160901143859.730826ed@redhat.com>
        <20160901124839.GU10153@twins.programming.kicks-ass.net>
        <20160901153042.465b864e@redhat.com>
        <20160901152802.GV10153@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Jonathan Corbet <corbet@lwn.net>, brouer@redhat.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901152802.GV10153@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Sep 2016 17:28:02 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Sep 01, 2016 at 03:30:42PM +0200, Jesper Dangaard Brouer wrote:
> > Still... enabled!
> > Hmmm.. more idea how to disable this???  
> 
> I think you ought to be able to assign yourself to the root cgroup,
> something like:
> 
>   echo $$ > /cgroup/tasks
> 
> or wheverever the cpu-cgroup controller is mounted at.
> 
> But its been a fair while since I touched any of that, its not a CONFIG
> I have enabled much.

I could not figure out how to disable autogroups, so I ended up
compiling the kernel without CONFIG_SCHED_AUTOGROUP.

  PID   PR   S  %CPU     TIME+ 	COMMAND
    3   20   R  20.7   0:53.05 	ksoftirqd/0
 9299   20   R  16.3   0:03.62 	udp_sink
 9296   20   S  16.0   0:03.59 	udp_sink
 9297   20   R  16.0   0:03.58 	udp_sink
 9298   20   R  16.0   0:03.57 	udp_sink
 9295   20   R  15.3   0:03.43 	udp_sink

Top new shows the CPU distribution is more correct, thus we can
concluded the artifact I saw was indeed caused by autogroup.

I can also confirm that my netperf UDP_STREAM tests now work again,
but I need around 32 parallel netperf to counter the effectiveness of
the ksoftirqd process.  While I only need 5 udp_sink programs.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
