From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] support for large number of network devices.
Date: Wed, 14 Jan 2004 13:39:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114213908.GA22653@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote :
> 
> When using pseudo network devices, and really big machines; there is
> sometimes a need to have a lot of network devices.  This replaces the
> existing 2.6.1 limit of 100 entries an was O(n^2)
> with a algorithm that will handle up to 32768 entries with O(n) behaviour.

	You may want to be careful about buffer overflow in
dev->name. The old code did not check for it, because it was replacing
'%d' with a most 2 char ('0' to '99').
	The new code may create overflow for device names such as :
		'reallylongname%d'
	And you don't seem the catch that (unless I overlooked something).

	The problem is more messy that it looks like, because there is
no sane way to handle overflow. You can return an error to the driver,
and the driver may bail out properly (or crash), but the end user has
no way to overcome the issue and get its card loaded (short of editing
the driver and recompiling the kernel).
	So, there is a bit of auding to do first. I know for example
the HostAP create such long names.
	But that's only my humble opinion ;-)

	Jean
