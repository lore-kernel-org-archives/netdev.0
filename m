From: Lee Revell <rlrevell@joe-job.com>
Subject: RE: My vote against eepro* removal
Date: Fri, 20 Jan 2006 19:45:45 -0500
Message-ID: <1137804346.3241.38.camel@mindpipe>
References: <AAD6DA242BC63C488511C611BD51F367323325@MAILIT.keba.co.at>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	John Ronciak <john.ronciak@gmail.com>,
	Adrian Bunk <bunk@stusta.de>, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932350AbWAUApu@vger.kernel.org>
To: kus Kusche Klaus <kus@keba.com>
In-Reply-To: <AAD6DA242BC63C488511C611BD51F367323325@MAILIT.keba.co.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-20 at 11:19 +0100, kus Kusche Klaus wrote:
> For a non-full preemption kernel, your patch moves the 500 us 
> piece of code from kernel to thread context, so it really 
> improves things. But is 500 us something to worry about in a
> non-full preemption kernel? 

Yes, absolutely.  Once exit_mmap (a latency regression which was
introduced in 2.6.14) and rt_run_flush/rt_garbage_collect (which have
always been problematic) are fixed, 500usecs will stick out like a sore
thumb even on a regular PREEMPT kernel.

Also, you should be able to capture this latency in /proc/latency trace
by configuring an -rt kernel with PREEMPT_DESKTOP and hard/softirq
preemption disabled.

Lee
