From: "David S. Miller" <davem@redhat.com>
Subject: Re: e100 "Ferguson" release
Date: Sun, 3 Aug 2003 00:32:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030803003239.4257ef24.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com>
	<3F2CA65F.8060105@pobox.com>
	<3F2CBA71.2070503@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F2CBA71.2070503@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Although I have not tried this latest patch, the existing e100 and e1000 in
> 2.4.21 seldom seem to return true to this method:  netif_queue_stopped(odev),
> even when the next hard_start_xmit() call fails.

Returning an error from hard_start_xmit() from normal ethernet
drivers is, frankly, a driver bug and should never happen.

I don't know if there is somehow something special about the
e100, but even if there is hard_start_xmit() failures can
be avoided by properly doing netif_queue_{stop,wakeup}() in
the right places.
