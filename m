From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: 15 Sep 2003 07:29:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063625359.1075.46.camel@jzny.localdomain>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010124F032@orsmsx402.jf.intel.com>
	 <1063370664.1028.85.camel@jzny.localdomain>
	 <3F620C90.5090903@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Feldman, Scott" <scott.feldman@intel.com>,
   Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com, ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F620C90.5090903@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-09-12 at 14:12, Ben Greear wrote:

> > 
> > Well, theres only one way out that device ;-> and it goes out at a max 
> > rate of Gige. If you have sustained incoming rates from the CPU(s) of
> > greater than Gige, then you are fucked anyways and you are better to
> > drop at the scheduler queue.
> 
> I have seen greater packets-per-second throughput when I increase 
> the TxDescriptor
> ring (and RxDescriptor ring) when using pktgen, which checks for enqueue 
> errors
> and re-queues as needed.  So, it could help the case where we are running
> at very high sustained speeds (or high packets-per-second rates).
> 

Have you tried increasing the s/ware queue instead?;-> Thats been
mentioned in about the last 10 posts.
Even though you care about what you refer as "very high sustained
speeds" type of apps, others may not. Infact i think the majority may
not: 
Think of that poor ssh login packet queued in behind 999 ftp packets in
the s/ware queue which is also above another 1000 ftp packets in the TX
DMA path. 

Whatever happened to good engineering such as the post from Donald? 

> >>I flunked that queuing theory class anyway, so what do I know?  Every
> >>time I get stuck in a traffic slug on the freeway, I think about that
> >>class.  Hey, that means my car is like an skb, so maybe longer roads
> >>would help?  Not!
> > 
> > 
> > 
> > Note we do return an indication that the packet was dropped. What you do
> > with that information is relative. TCP makes use of it in the kernel
> > which makes sense. UDP congestion control is mostly under the influence
> > of the UDP app in user space. The impedance between user space and
> > kernel makes that info useless to the UDP app especially in cases when
> > the system is overloaded (which is where this matters most). This is of
> > course theory and someone who really wants to find out should
> > experiment. I would be pleasantly shocked if it turned out the info to
> > the UDP app was useful. An interesting thing to try , which violates
> > UDP, is to have UDP requeue a packet back to the socket queue in the
> > kernel everytime an indication is received that the scheduler queue
> > dropped the packet. User space by virtue of UDP sock queue not emptying
> > should find out soon and slow down.
> 
> Um, I doubt the UDP protocol says you MUST drop packets when you reach
> congestion...it just says that you _CAN_ drop the packet.  

Which UDP spec did you read?;-> Try to do voice or any "realtime" apps
which use UDP precisely because it doesnt do what you described

> Slowing
> down user-space is exactly what you want to do in this case because it
> saves user-space CPU, and it saves the user-space program from having
> to deal (so often) with dropped packets.
> 
>
> Already, if the socket queue is full, poll/select will block, you'll get
> -EBUSY returned, and/or your application will block on a wait queue....
> Any of these allow the user space program to immediately back off,
> saving the whole system work.
> 
[handwaving deleted]

Why dont you try an experiment to show that you can pass the signal to
user space? 


> > 
> > To give anology to your car, if you only find out half way later that
> > there was a red light a few meters back then that info is useless. If
> > you dont get hit and reverse you may find that infact the light has
> > turned to green which is again useless ;-> 
> 
> So much better to have stopped the car earlier and kept him out of the
> intersection in the first place :)
> 

Try that experiment friend and see if you could have stopped the car in
time;->

cheers,
jamal
