From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: netif_poll_disable() hangs
Date: Mon, 08 Sep 2003 03:17:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F5C2D1A.5050500@pobox.com>
References: <20030907232145.6ec197fd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20030907232145.6ec197fd.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Very simple:
> 
> 	ifup eth0
> 	ifdown eth0
> 	ifup eth0
> 	ifdown eth0	<- hangs in dev_close -> netif_poll_disable()
> 
> 
> Because the first close sets __LINK_STATE_RX_SCHED and nothing ever clears
> it.  


Weird.  Looking at older 2.4 and 2.6, the bit has always been set that way.

process_backlog() has always been the only site that ever clears that 
bit...  maybe process_backlog() is called when interface is up'd, which 
is why it worked before (and should be working now)?

	Jeff
