From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 1 Jun 2005 15:45:26 -0500
Message-ID: <92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	<20050531105939.7486e071@dxpl.pdx.osdl.net>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
In-Reply-To: <20050531105939.7486e071@dxpl.pdx.osdl.net>
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


On May 31, 2005, at 12:59, Stephen Hemminger wrote:

> Here are some patches:
>     * allow phy's to be modules
>     * use driver owner for ref count
>     * make local functions static where ever possible

I agree with all these.

>     * get rid of bus read may sleep implication in comment.
>       since you are holding phy spin lock it better not!!

But not this one.  The phy_read and phy_write functions are reading  
from and writing to a bus.  It is a reasonable implementation to have  
the operation block in the bus driver, and be awoken when an  
interrupt signals the operation is done.  All of the phydev spinlocks  
have been arranged so as to prevent the lock being taken during  
interrupt time.

Unless I've misunderstood spinlocks (it wouldn't be the first time),  
as long as the lock is never taken in interrupt time, it should be ok  
to hold the lock, and wait for an interrupt before clearing the lock.

Andy Fleming
