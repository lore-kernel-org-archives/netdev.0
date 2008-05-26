From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Tue, 27 May 2008 00:20:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805262348240.24924@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <Pine.LNX.4.64.0805261550340.16829@wrl-59.cs.helsinki.fi>
 <20080526135940.GB24870@elte.hu> <20080526141252.GA31352@elte.hu>
 <Pine.LNX.4.64.0805261745010.16829@wrl-59.cs.helsinki.fi> <20080526162328.GA9089@elte.hu>
 <Pine.LNX.4.64.0805261926260.24924@wrl-59.cs.helsinki.fi> <20080526165407.GB24098@elte.hu>
 <Pine.LNX.4.64.0805261956090.24924@wrl-59.cs.helsinki.fi> <20080526181216.GA12400@elte.hu>
 <20080526204140.GA13186@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47098 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbYEZVUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 17:20:09 -0400
In-Reply-To: <20080526204140.GA13186@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

...Added Pavel & Denis.

On Mon, 26 May 2008, Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > > It's well possible that e.g., net namespaces have some bug in 
> > > handling of orphaned tcp.
> > 
> > yes, that would match the symptoms i think. I half-assumed that it's a 
> > state machine problem so i didnt even check what the reader does - and 
> > in this case it appears to not exist at all anymore ;-)

I keep wondering why distcc in the first place has a connection orphaned
before it has read all data from it, I guess it should not yet be
speculatively executing anything or so :-). Anyway, there should be RST
due to that data because nobody is going read it after the process in gone 
but since state is still ESTABLISHED, I doubt that tcp_close() was ever 
executed which adds some strangeness.

> after ~7 hours of uptime the networking code produced this assertion:
> 
>  [25441.140000] KERNEL: assertion (!sk->sk_ack_backlog) failed at 
>  net/ipv4/inet_connection_sock.c (642)

...I checked /proc/net/tcp output you gave earlier, and indeed, it shows 
1 in sk->sk_ack_backlog of the LISTENing socket at that time.

> no further information in the logs. I kept the failing system booted up 
> for 8 hours and will reboot it now.



-- 
 i.
