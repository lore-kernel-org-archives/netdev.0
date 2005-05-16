From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: patch tulip-natsemi-dp83840a-phy-fix.patch added to -mm tree
Date: Mon, 16 May 2005 12:46:09 -0400
Message-ID: <4288CE51.1050703@pobox.com>
References: <200505101955.j4AJtX9x032464@shell0.pdx.osdl.net> <42881C58.40001@pobox.com> <20050516050843.GA20107@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, T-Bone@parisc-linux.org, varenet@parisc-linux.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261741AbVEPQqW@vger.kernel.org>
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20050516050843.GA20107@colo.lackof.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simply ensure that tulip_select_media() is always called from a process 
context. Then can you delay all you want.  Several of the calls are 
already this way, so that leaves two cases:

1) called from timer context, from the media poll timer

2) called from spin_lock_irqsave() context, in the ->tx_timeout hook.

The first case can be fixed by moved all the timer code to a workqueue. 
  Then when the existing timer fires, kick the workqueue.

The second case can be fixed by kicking the workqueue upon tx_timeout 
(which is the reason why I did not suggest queue_delayed_work() use).

See, it's not rocket science :)

	Jeff
