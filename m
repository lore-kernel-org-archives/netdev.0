From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFR: new SiS gige driver
Date: Sun, 10 Aug 2003 21:07:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F36EC53.8040404@pobox.com>
References: <20030808173932.GA4077@gtf.org> <20030809141533.GB4539@wotan.suse.de> <3F350CC8.3090605@pobox.com> <20030809152747.GA1618@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030809152747.GA1618@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> The netif_wake_queue is lost. It's only deadly when clean some packets
> clears the full TX ring, otherwise it will likely recover with the 
> next TX finished interrupt but give suboptimal performance.
> 
> Fix is to do the my queue is full -> netif_stop_queue inside the spinlock.

"a fix" not "the fix" :)

You can also do what some drivers do, and move the netif_queue_stop 
above the queue-packet-to-hw section of driver's ->hard_start_xmit. 
Then when this uncommon race occurs, you are guaranteed another 
TX-complete interrupt, even if the queue is stopped prematurely.

A lot of drivers netif_stop_queue after, not before, so this is indeed 
an issue that needs paying attention to.

	Jeff
