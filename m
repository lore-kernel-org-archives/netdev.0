From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 17:33:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031105173311.0b9f8bfc.shemminger@osdl.org>
References: <OF5FCB025A.8A78EF16-ON88256DD6.0006FAFE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OF5FCB025A.8A78EF16-ON88256DD6.0006FAFE@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 5 Nov 2003 17:20:06 -0800
Krishna Kumar <kumarkr@us.ibm.com> wrote:

> 
> 
> 
> 
> So how will this guarantee that the dev is valid after the dev_put() long
> enough to do the
> BUG_ON() and dev->destructor code ? Won't the same panic happen ?
> 

Because the code there should be able to depend on having the last reference.
No other code should be able to find the dev to get a new reference to it,
since it is no longer in the dev_list.  Code that does dev_hold's
without already having a reference is just not playing fair. 


> Any idea how the dev gets freed up ? I was still in the old 2.4 kernel mode
> thinking that
> dev_put does it, but it seems to be done by using the class/object stuff in
> free_netdev().
> 
> Won't a driver doing a unregister followed by a free_netdev still panic the
> system if we
> reference the dev at a later stage (even with the put at this place) ?
> 
> thanks,
> 
> - KK
> 
