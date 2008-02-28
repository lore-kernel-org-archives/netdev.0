From: Willy Tarreau <w@1wt.eu>
Subject: Re: SO_REUSEADDR not allowing server and client to use same port
Date: Thu, 28 Feb 2008 21:36:17 +0100
Message-ID: <20080228203616.GD8953@1wt.eu>
References: <47C6FA2A.5030302@alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"Kittlitz, Edward (Ned)" <nkittlitz@alcatel-lucent.com>,
	asweeney@alcatel-lucent.com,
	"Polhemus, William (Bart)" <bpolhemus@alcatel-lucent.com>,
	netdev@vger.kernel.org
To: Nebojsa Miljanovic <neb@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2201 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510AbYB1Ug1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 15:36:27 -0500
Content-Disposition: inline
In-Reply-To: <47C6FA2A.5030302@alcatel-lucent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc'd netdev]

On Thu, Feb 28, 2008 at 12:15:06PM -0600, Nebojsa Miljanovic wrote:
> Hello all,
> I have seen similar complaints about this issue before in the list archive, but
> I have not seen any resolution. So, I am posting the question again in hope of
> getting some replies.
> 
> Currently, Linux does not allow reuse of same local port for both TCP server and
> TCP client. I understand that there may be a need to prevent two servers from
> binding to the same local port, but having 1 server and 1 outgoing client use it
> should be allowed. Other Unix like operating systems do allow it.

I've been encountering the need for SO_REUSEPORT as implemented on some BSD
for instance. It allows any process to explicitly permit another one to bind
to the same IP:port provided that it also sets its socket with SO_REUSEPORT.
This is a real requirement when you need to restart a service without any
service disruption.

In the end, I've written a trivial patch for 2.4 (but most likely 2.6 would
use nearly the same one). I noticed that the conflict detection logic already
distinguished between 3 cases: sk->reuse==0, sk->reuse==1, sk->reuse >1.
sk->reuse was set to 1 with SO_REUSEADDR. I simply had to make SO_REUSEPORT
do sk->reuse |= 2 to get everything working as expected.

I don't know yet if it is as easy to do in 2.6, but if there is a possible
acceptance of including this useful feature into mainline, I can try to
work a patch (possibly cleaner than my existing one for 2.4).

Regards,
Willy

