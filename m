From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ref count bug in MLDv2
Date: Wed, 12 Nov 2003 17:58:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112175826.13850359.davem@redhat.com>
References: <OF9FB7F6ED.3B4FEB1E-ON88256DDD.0002886E@us.ibm.com>
	<Pine.LNX.4.44.0311121630100.1794-100000@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, netdev@oss.sgi.com, dlstevens@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0311121630100.1794-100000@linux.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 Nov 2003 16:56:20 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> Dave Stevens and I  found this problem when the device is going down,
> mc_destroy_dev() calls igmp6_group_dropped which checks for IFF_UP before
> calling mld_add_delrec and posting a timer.
> 
> IFF_UP need not be set though the device is going down (eg last address
> deletion). So timer can get started at this time. The problem is that
> when the timer fires (after ifdown is over) for the last time
> (mld_ifc_timer_expire), it does a __in6_dev_put() and that will not free
> up the idev.
> 
> To fix that that the check must be for idev->dead instead.

Applied, thanks a lot Krishna.
