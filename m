From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Tue, 22 Oct 2002 19:37:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB60B4E.1090004@candelatech.com>
References: <Pine.GSO.4.30.0210222113240.24323-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

> I think you misunderstood. Look at the dev->weight.

Yep, I was definately confused.  I don't see how changing the
value as I did could affect anything in a good way, but I definately
saw changes in dropped packets...maybe it was too late at night :)

So, after further looking at the code, it appears that the dev->weight
is basically hard-coded in the tulip driver, and the weight_p value
in dev.c (and settable though sysctl) is not used anywhere except
netdev_init (ie, not soon enough to actually set via sysctl).

Think we should add an IOCTL to change the weight of a device
dynamically?  (I want my e1000 and tg3 to have higher weight than
the tulip nics, I imagine)

Is there a ready-built proc interface to do things to individual devices?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
