From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 05/18]  net/s2io: replace 	schedule_timeout() with msleep()
Date: Mon, 01 Nov 2004 13:03:10 -0500
Message-ID: <41867A5E.4040301@pobox.com>
References: <E1CO1vc-00022t-N2@sputnik> <4184C7EE.5070107@pobox.com> <20041101183118.GA1730@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: janitor@sternwelten.at, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20041101183118.GA1730@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nishanth Aravamudan wrote:
> On Sun, Oct 31, 2004 at 06:09:34AM -0500, Jeff Garzik wrote:
> 
>>janitor@sternwelten.at wrote:
>>
>>>@@ -2846,11 +2838,10 @@ static int s2io_ethtool_idnic(struct net
>>>		sp->id_timer.data = (unsigned long) sp;
>>>	}
>>>	mod_timer(&sp->id_timer, jiffies);
>>>-	set_current_state(TASK_INTERRUPTIBLE);
>>>	if (data)
>>>-		schedule_timeout(data * HZ);
>>>+		msleep_interruptible(data * 1000);
>>
>>
>>clearly wants ssleep() here
> 
> 
> Even though ssleep() is in TASK_UNINTERRUPTIBLE? In cases where the
> existing code used TASK_INTERRUPTIBLE, but was sleeping in terms of
> seconds, I left it as msleep_interruptible, since ssleep_interruptible()
> doesn't exist.

Right:  create ssleep_interruptible()  :)

	Jeff
