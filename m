From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 22:11:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D87E0C2.6040004@mandrakesoft.com>
References: <3D87A264.8D5F3AD2@digeo.com>	<20020917.143947.07361352.davem@redhat.com>	<3D87A4A2.6050403@mandrakesoft.com> <20020917.144911.43656989.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@digeo.com, manfred@colorfullife.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@mandrakesoft.com>
>    Date: Tue, 17 Sep 2002 17:54:42 -0400
> 
>    David S. Miller wrote:
>    > Any driver should be able to get the NAPI overhead to max out at
>    > 2 PIOs per packet.
>    
>    Just to pick nits... my example went from 2 or 3 IOs [depending on the 
>    presence/absence of a work loop] to 6 IOs.
>    
> I mean "2 extra PIOs" not "2 total PIOs".
> 
> I think it's doable for just about every driver, even tg3 with it's
> weird semaphore scheme takes 2 extra PIOs worst case with NAPI.
> 
> The semaphore I have to ACK anyways at hw IRQ time anyways, and since
> I keep a software copy of the IRQ masking register, mask and unmask
> are each one PIO.


You're looking at at least one extra get-irq-status too, at least in the 
classical 10/100 drivers I'm used to seeing...

	Jeff
