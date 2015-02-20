From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by
 set_current_state()
Date: Fri, 20 Feb 2015 11:44:37 -0800
Message-ID: <1424461477.5565.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
	 <1424455977-21903-6-git-send-email-fabf@skynet.be>
	 <54E77E34.6050909@cogentembedded.com>
	 <20150220185800.GR2896@worktop.programming.kicks-ass.net>
	 <1424460713.5565.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Fabian Frederick <fabf@skynet.be>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424460713.5565.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-02-20 at 11:31 -0800, Eric Dumazet wrote:
> On Fri, 2015-02-20 at 19:58 +0100, Peter Zijlstra wrote:
> > On Fri, Feb 20, 2015 at 09:34:28PM +0300, Sergei Shtylyov wrote:
> > > Hello.
> > > 
> > > On 02/20/2015 09:12 PM, Fabian Frederick wrote:
> > > 
> > > >Use helper functions to access current->state.
> > > >Direct assignments are prone to races and therefore buggy.
> > > 
> > > >current->state = TASK_RUNNING is replaced by __set_current_state()
> > > 
> > >    You sometimes use __set_current_state() and sometimes set_current_state().
> > 
> > It depends on which state; setting yourself TASK_RUNNING is free of
> > wakeup races -- you're already running after all, so it can safely use
> > __set_current_state().
> 
> Maybe this might be self documented in set_current_state(),
> as we have about 120 calls to __set_current_state(TASK_RUNNING)

And about 138 calls to set_current_state(TASK_RUNNING)
