From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Fri, 13 Feb 2004 21:36:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213213606.5a13cc76.davem@redhat.com>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	<20040211200549.736fa8b3.davem@redhat.com>
	<1076561489.1032.65.camel@jzny.localdomain>
	<1076561998.1035.72.camel@jzny.localdomain>
	<1076562282.1033.76.camel@jzny.localdomain>
	<20040211211536.23e97997.davem@redhat.com>
	<1076563502.1031.85.camel@jzny.localdomain>
	<1076564638.1033.91.camel@jzny.localdomain>
	<20040211215142.7f817513.davem@redhat.com>
	<1076566176.1033.94.camel@jzny.localdomain>
	<20040211222259.776ad818.davem@redhat.com>
	<402D54D6.5070708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, qnex@atlantis.knm.org.pl, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <402D54D6.5070708@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 13 Feb 2004 23:51:02 +0100
Patrick McHardy <kaber@trash.net> wrote:

> while looking for other devices that may be affected I noticed
> this fix changes behaviour in dev_activate. dev_activate creates
> pfifo_fast queues for devices with tx_queue_len != 0 and noqueue
> qdiscs otherwise.

Thanks for spotting this.

> Although it is uncomfortable for some users, I don't know if there
> is anything to fix at all. Work-conserving qdiscs are useless for
> virtual devices, as you say there is maximum one packet queued at
> any time. For non-work-conserving qdiscs with default pfifo qdiscs
> as leaves, I'd say it is simply a configuration error not to increase
> tx_queue_len. Even with a length of 1 (or a off-by-one), you won't get
> good results, except when the traffic is already well-formed. All that
> is changed is that nonsensical configurations stop working.

Another way to view this is that configurations that, while nonsensical,
used to send packets properly no longer do.

However, I do agree with you, and we should not promote this kind of crap.
I'm going to revert the changeset that set tx_queue_len to 1 in the tunnels.

Thanks again Patrick.
