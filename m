From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] MII bus API for PHY devices
Date: Fri, 19 Nov 2004 18:04:07 -0600
Message-ID: <B2AF8092-3A87-11D9-B023-000393C30512@freescale.com>
References: <069B6F33-341C-11D9-9652-000393DBC2E8@freescale.com> <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com> <1100820391.25521.14.camel@gaston> <97DA0EF0-3A70-11D9-B023-000393C30512@freescale.com> <1100904184.3856.46.camel@gaston>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason McMullan <jason.mcmullan@timesys.com>,
        Linux Kernel list <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1100904184.3856.46.camel@gaston>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Nov 19, 2004, at 16:43, Benjamin Herrenschmidt wrote:

> On Fri, 2004-11-19 at 15:18 -0600, Andy Fleming wrote:
>
>> So when you say instantiated, would you consider calling an "attach"
>> function with the phy_id and bus_id of the desired PHY instantiation?
>> I'm fine with that.  The PHY would need to be able to send
>> notifications to the enet controller (currently done through a
>> callback).  I'm interested in ideas on how the notifier could be used
>> (I have a distaste for callbacks).
>
> Look at the notifier lists in include/linux/notifier.h

Ok, will do.

>
>> Autopoll features sound pretty neat.  I think the system should 
>> support
>> that.
>
> But that becomes MAC-dependant again... That means you'd need 1) a way
> for the MAC driver to ask the PHY driver what register it wants
> autopolled, and a function in the PHY driver for the MAC to call when 
> it
> detects a change. Also, autopoll is broken in some MACs...

What I'm envisioning here is that the driver would be able to tell the 
PHY infrastructure that it's going to do its own thing, and then make 
use of the reading/configuring part of the infrastructure, similar to 
how sungem and gianfar are currently set up.  But they would have the 
option of letting the infrastructure also handle the status updates.  
And, of course, the driver would not go through the effort to use 
autopoll if it were broken.

>
>>   PHY interrupts are supported (they work quite well on my 85xx
>> system), as is timer-based polling.  Do you really think that there 
>> are
>> special cases which can't be handled using a library similar to the
>> sungem_phy one?
>
> Nope. I think timer based polling with a sungem-like fallback mecanism
> to forced speeds would be nice.

Yes, I agree.  The system I currently have does fallback to forced, 
though it doesn't yet support the "magic aneg" feature you mentioned.  
But that should be easy to add, and so it shall be.


Andy Fleming
