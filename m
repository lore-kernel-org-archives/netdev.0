From: Stefan Rompf <srompf@isg.de>
Subject: Re: Deadlock in sungem/ip_auto_config/linkwatch
Date: Mon, 5 Jan 2004 15:50:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401051550.51063.srompf@isg.de>
References: <1073307882.2041.98320.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ostrowski <mostrows@watson.ibm.com>, netdev@oss.sgi.com
In-Reply-To: <1073307882.2041.98320.camel@brick.watson.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Montag, 05. Januar 2004 14:07 schrieb Michal Ostrowski:

> ic_open_devs grabs rtnl_sem with an rtnl_shlock() call.
>
> The sungem driver at some point calls gem_init_one, which calls
> netif_carrier_*, which in turn calls schedule_work (linkwatch_event).
>
> linkwatch_event in turn needs rtnl_sem.

Good catch! The sungem driver shows clearly that we need some way to remove 
queued work without scheduling and waiting for other events.

I will change the linkwatch code to use rtnl_shlock_nowait() and backoff and 
retry in case of failure this week. Call it a workaround, but it increases 
overall system stability.

Btw, what is the planned difference between rtnl_shlock() and rtnl_exlock()? 
Even though the later is a null operation right now, I don't want to hold 
more locks than needed in the linkwatch code.

Stefan

-- 
"doesn't work" is not a magic word to explain everything.
