From: Ben Greear <greearb@candelatech.com>
Subject: Netdevice reference counting issues in net/core/dv.c
Date: Sat, 27 Aug 2005 23:42:54 -0700
Message-ID: <43115CEE.9030306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dv.c has several issues.

First, it uses the check_args method to find the
device.  It acquires a hold on the device and then
drops it in the same method.  Upon return from this
check_args method, code then continues to use the reference
to the device.  This could lead to access-after-free errors.

Also, check_args has an arbitrary device-index check to make
sure it is less that 1000.  This is bogus since we can have many
more devices than that...

If there is a maintainer that wants to fix this, please be my
guest.  Otherwise, I'll make a stab at fixing it as part of
my ref-count debugging work.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
