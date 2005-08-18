From: Chris Wedgwood <cw@f00f.org>
Subject: Re: overflows in /proc/net/dev
Date: Thu, 18 Aug 2005 09:33:58 -0700
Message-ID: <20050818163358.GA19554@taniwha.stupidest.org>
References: <1124350090.29902.8.camel@basti79.freenet-ag.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932287AbVHRQeJ@vger.kernel.org>
To: Sebastian Cla?en <Sebastian.Classen@freenet-ag.de>
Content-Disposition: inline
In-Reply-To: <1124350090.29902.8.camel@basti79.freenet-ag.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 18, 2005 at 09:28:10AM +0200, Sebastian Cla?en wrote:

> in struct net_device_stats all members are defined as unsgined
> long. In time of gigabit ethernet this takes not long to overflow.

It should still take an appreciable amount of time surely?  We can
detect those wraps in userspace and deal with it as needed.

> Are there any plans to change these coutners to unsigned long long?

It comes up from time to time (see below).

> I saw in ifconfig source code the byte and packet counters are
> already defined as unsigned long long.

ifconfig is userspace.


[...]

>  struct net_device_stats
>  {
> -	unsigned long rx_packets;		/* total packets received	*/
> -	unsigned long tx_packets;		/* total packets transmitted	*/
> -	unsigned long rx_bytes;		/* total bytes received 	*/
> -	unsigned long tx_bytes;		/* total bytes transmitted	*/
> +	unsigned long long rx_packets;		/* total packets received	*/
> +	unsigned long long tx_packets;		/* total packets transmitted	*/
> +	unsigned long long rx_bytes;		/* total bytes received 	*/
> +	unsigned long long tx_bytes;		/* total bytes transmitted	*/

I thought the concensurs here was that because doing reliable atomic
updates of 64-bit values isn't possible on some (most?) 32-bit
architectures so we need additional locking to make this work which is
undesirable?  (It might even be a FAQ by now as this comes up fairly
often).
