From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: The recent free_netdev() conversion...
Date: Mon, 01 Sep 2003 11:58:47 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F536CB7.6060404@pobox.com>
References: <3F535EBD.6090401@pobox.com> <20030901075345.4c35e3e6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030901075345.4c35e3e6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 01 Sep 2003 10:59:09 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>     err_out:
>>	kfree(dev);
> 
>  ...
> 
>>The "kfree" needs to be a free_netdev() too.
> 
> 
> If the 'dev' hasn't been given to register_netdev() it
> really doesn't need to be free_netdev().  It's just memory
> until it has been given to the device layer.


True, but for long term, it's best to use free_netdev().  Besides 
naturally pairing with alloc_foodev(), if we ever decide to have 
alloc_netdev() perform more than one allocation, free_netdev() will 
already be in place to handle the multiple de-allocations.

	Jeff
