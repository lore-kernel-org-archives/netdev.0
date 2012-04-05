From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [3.4-rc1][Regression][network wireless] 'task xxxx blocked for
 more than 120 seconds' after resume
Date: Thu, 5 Apr 2012 12:32:54 +0200
Message-ID: <20120405103254.GE2378@redhat.com>
References: <201204022157.05598.maciej.rutecki@gmail.com>
 <1333440469.3574.0.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>, maciej.rutecki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44193 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753373Ab2DEKeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 06:34:14 -0400
Content-Disposition: inline
In-Reply-To: <1333440469.3574.0.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 03, 2012 at 10:07:49AM +0200, Johannes Berg wrote:
> -ilw
> +netdev
> 
> I have no idea what this could be, but I'm almost certain it's not
> caused by our wireless driver. Looks more like rtl8169 is to blame.

I'm not sure. Looks like there is deadlock or infinite loop in process
that holds rtnl lock. This can be wireless driver, wired driver or
generic network code bug.

Maciej, please recompile with CONFIG_LOCKDEP and check if it will not
find any deadlock. If not, when problem will happen please do

echo w > /proc/sysrq-trigger
dmesg -c > dmesg1.txt
echo t > /proc/sysrq-trigger
dmesg > dmesg2.txt

and provide those files.

Additionally there are also lot in dmesg:

 netlink: 140 bytes leftover after parsing attributes.

This need to be investigated as well. Perhaps you could modify error
message, to show what netlink messages/attributes are processed.

Thanks
Stanislaw
