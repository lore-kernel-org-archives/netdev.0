From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 10:35:02 +0100
Message-ID: <F57561A93EFF5E88729A8D53@nimrod.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>	
 <1304785589.3207.5.camel@edumazet-laptop>	
 <178E8895FB84C07251538EF7@Ximines.local>	
 <1304793174.3207.22.camel@edumazet-laptop>	
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:33839 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752157Ab1EHJfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 05:35:06 -0400
In-Reply-To: <1304838742.3207.45.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

--On 8 May 2011 09:12:22 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> By the way, if I change HZ from 1000 to 100 I now have ten times slower
> result :

I repeated that test here. With HZ set to 1000 I got a total time of
4.022 seconds to remove 100 interfaces, of which:

 Total 3.03808 Usage 199 Average 0.01527 elsewhere
 Total 0.93992 Usage 200 Average 0.00470 synchronizing

as opposed to a total of 27.917 seconds with HZ set to 100, of which

 Total 18.98515 Usage 199 Average 0.09540 elsewhere
 Total 8.77581 Usage 200 Average 0.04388 synchronizing

Not quite a factor of 10 improvement, but nearly.

I have CONFIG_RCU_FAST_NO_HZ=y

I suspect this may just mean an rcu reader holds the rcu_read_lock
for a jiffies related time. Though I'm having difficulty seeing
what that might be on a system where the net is in essence idle.

-- 
Alex Bligh
