From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 1 Jun 2005 17:42:56 -0500
Message-ID: <A07C472D-BA2E-4C29-9DA2-F983DC9CDEDB@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	<20050531105939.7486e071@dxpl.pdx.osdl.net>
	<92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com>
	<429E2653.6010101@osdl.org>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
In-Reply-To: <429E2653.6010101@osdl.org>
To: Stephen Hemminger <shemminger@osdl.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org


On Jun 1, 2005, at 16:19, Stephen Hemminger wrote:

> Andy Fleming wrote:
>>
>> But not this one.  The phy_read and phy_write functions are  
>> reading  from and writing to a bus.  It is a reasonable  
>> implementation to have  the operation block in the bus driver, and  
>> be awoken when an  interrupt signals the operation is done.  All  
>> of the phydev spinlocks  have been arranged so as to prevent the  
>> lock being taken during  interrupt time.
>>
>> Unless I've misunderstood spinlocks (it wouldn't be the first  
>> time),  as long as the lock is never taken in interrupt time, it  
>> should be ok  to hold the lock, and wait for an interrupt before  
>> clearing the lock.
>>
>
>
> The problem is that sleeping is defined in the linux kernel as  
> meaning waiting on a mutual exclusion
> primitive (like semaphore) that puts the current thread to sleep.  
> It is not legal to sleep with a spinlock held.
> In the phy_read code you do:
>     spin_lock_bh(&bus->mdio_lock);
>    retval = bus->read(bus, phydev->addr, regnum);
>    spin_unlock_bh(&bus->mdio_lock);
>
> If the bus->read function were to do something like start a request  
> and wait on a semaphore, then
> you would be sleeping with a spin lock held.  So bus->read can not  
> sleep! (as sleep is defined in the
> linux kernel).

Hmm...  I understand this reasoning, but I still need a way for a bus  
read to wait for an interrupt before returning.  I suppose I can just  
have the code spin while it waits, but that seems wrong, somehow.   
I'm open to any suggestions.
