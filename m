From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFR: new SiS gige driver
Date: Sat, 09 Aug 2003 11:01:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F350CC8.3090605@pobox.com>
References: <20030808173932.GA4077@gtf.org> <20030809141533.GB4539@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030809141533.GB4539@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> * netif_stop_queue in hard_start_xmit is not protected against the interrupt by the 
> spinlock. That's racy, isn't it?

Shouldn't be, if done right.  If the interrupt runs a TX completion 
cycle, it will run the code
	if (work_done && netif_queue_stopped(dev))
		netif_wake_queue(dev)

Since ->hard_start_xmit is guaranteed never to be called if the queue is 
stopped, you also guaranteed that netif_wake_queue and ->hard_start_xmit 
are mutually exclusive.

This of course assumes certain details about the driver implementation, 
which may be missing from that driver's TX completion handler :)

Thanks for your, and everybody else's comments.  They are being saved.

	Jeff
