From: Ben Greear <greearb@candelatech.com>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Mon, 21 Oct 2002 23:07:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB4EB25.5050706@candelatech.com>
References: <Pine.GSO.4.30.0210210826440.17911-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> In addition to solve your skb problem pick Roberts latest
> recycling patch at:
> ftp://robur.slu.se/pub/Linux/net-development/skb_recycling/recycle12.pat
> The driver i pointed to above has skb-recycling built in.

Robert, I am porting the existing tulip + your napi patch to support
skb-recycling.  (I realize someone has probably done that, but I
can't find it...Jamal's links are busted!)

In the help file, you suggest this at close:

         for (i=0; i<NR_CPUS; i++) {
                 if(adapter->cnt[i]) {
                         current->state = TASK_INTERRUPTIBLE;
                         schedule_timeout(1);
                 }
         }

I think the second if should probably be while, ie like this:

         for (i=0; i<NR_CPUS; i++) {
                 while(adapter->cnt[i]) {
                         current->state = TASK_INTERRUPTIBLE;
                         schedule_timeout(1);
                 }
         }

Otherwise, you race, and may delete an object that is still in use
somewhere up the stack.

Let me know if I'm nuts!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
