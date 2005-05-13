From: Arthur Kepner <akepner@sgi.com>
Subject: Re: Perf data with recent tg3 patches
Date: Fri, 13 May 2005 16:57:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505131648140.14917@linux.site>
References: <Pine.LNX.4.61.0505121942190.14917@linux.site>
 <20050512.211935.67881321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-317892268-1116028671=:14917"
Cc: mchan@broadcom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050512.211935.67881321.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-317892268-1116028671=:14917
Content-Type: TEXT/PLAIN; charset=US-ASCII


On Thu, 12 May 2005, David S.Miller wrote:

> ......
> The tg3_interrupt coalesce patch from me is supposed
> to be applied on top of my tagged status patch.
> 

OK, but the "tagged status" patch and the "hw 
coalescing infrastructure" patch aren't really 
dependent, right? 

In any case, I've repeated the measurements with 
both patches. Same experiment as yesterday. 

The data is in the attached graphs is labelled as follows:
---------------------------------------------------------
base              : is a "vanilla" 2.6.12-rc3 kernel
base+[1]+...+[i]  : "vanilla" 2.6.12-rc3 kernel + patches 
                    as labelled below

[1] http://marc.theaimsgroup.com/?l=linux-netdev&m=111446723510962&w=2
    (This is one of a series of 3 patches - the others can't be 
     found in the archive. But they're all in 2.6.12-rc4.)
[2] http://marc.theaimsgroup.com/?l=linux-netdev&m=111567944730302&w=2
    ("tagged status" patch)
[3] http://marc.theaimsgroup.com/?l=linux-netdev&m=111586526522981&w=2
    ("hw coalescing infrastructure" patch)

The data I sent yesterday was also with 2.6.12-rc3 (I 
mistakenly said it was rc2.) Also, I should have said 
that I only used the default coalescence parameters 
with [3] - didn't tune them with ethtool. Same is true 
of today's data.

The graphs show that the tagged status patch ([2]) is 
associated with fewer received packets/interrupt and 
higher CPU utilization. I found that the reason is that, 
under high receive load, most of the time (~80%) the 
tag in the status block changes between the time that 
it's read (and saved as last_tag) in tg3_poll(), and when 
it's written back to MAILBOX_INTERRUPT_0 in 
tg3_restart_ints(). If I understand the way the status 
tag works, that means that the card will immediately 
generate another interrupt. That's consistent with 
what I'm seeing - a much higher interrupt rate when the 
tagged status patch is used.

--
Arthur






--8323584-317892268-1116028671=:14917
Content-Type: IMAGE/png; name="cpu_vs_link.3.png"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0505131657510.14917@linux.site>
Content-Description: CPU utilization
Content-Disposition: attachment; filename="cpu_vs_link.3.png"

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
PzX2XxjA9QfNAAAAAElFTkSuQmCC

--8323584-317892268-1116028671=:14917
Content-Type: IMAGE/png; name="packets_vs_link.3.png"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0505131657511.14917@linux.site>
Content-Description: Received Packets/Interrupt
Content-Disposition: attachment; filename="packets_vs_link.3.png"

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
RU5ErkJggg==

--8323584-317892268-1116028671=:14917--
