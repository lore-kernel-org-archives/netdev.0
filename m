From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2.6] vlan - device refcount bug.
Date: Tue, 03 Aug 2004 13:36:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FF740.5060903@candelatech.com>
References: <20040803131425.503f8f45@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803131425.503f8f45@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> If you rmmod a network device that is in a vlan, the system hangs waiting
> for the refcount to go to zero, because it is -1.  The problem is that the
> vlan notifier does an extra dev_put in NETDEV_UNREGISTER case of notifier.

Good catch.  It would seem to me that it would be good to have a
BUG() or similar to catch any instance of the reference count going
negative.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
