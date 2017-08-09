From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hv_set_ifconfig.sh double check before setting ip
Date: Tue, 08 Aug 2017 21:11:50 -0700 (PDT)
Message-ID: <20170808.211150.2070475124549651350.davem@davemloft.net>
References: <20170808135345.17027-1-otubo@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@linuxdriverproject.org, sthemmin@microsoft.com,
        haiyangz@microsoft.com, kys@microsoft.com
To: otubo@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170808135345.17027-1-otubo@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eduardo Otubo <otubo@redhat.com>
Date: Tue,  8 Aug 2017 15:53:45 +0200

> This patch fixes the behavior of the hv_set_ifconfig script when setting
> the interface ip. Sometimes the interface has already been configured by
> network daemon, in this case hv_set_ifconfig causes "RTNETLINK: file
> exists error"; in order to avoid this error this patch makes sure double
> checks the interface before trying anything.
> 
> Signed-off-by: Eduardo Otubo <otubo@redhat.com>

And if the daemon sets the address after you test it but before
you try to set it in the script, what happens?

This is why I hate changes like this.  They don't remove the problem,
they make it smaller.  And smaller in a bad way.  Smaller makes the
problem even more harder to diagnose when it happens.

There is implicitly no synchonization between network configuration
daemons and things people run by hand like this script.

So, caveat emptor.

I'm not applying this, sorry.
