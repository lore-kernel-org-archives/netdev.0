From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 11:20:59 -0800
Message-ID: <OF064EFE49.6C80BD18-ON882570D7.00695B9C-882570D7.006A3661@us.ibm.com>
References: <20051214184147.GO23384@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	sri@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964905AbVLNTUT@vger.kernel.org>
In-Reply-To: <20051214184147.GO23384@wotan.suse.de>
To: Andi Kleen <ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It has a lot
> more users that compete true, but likely the set of GFP_CRITICAL users
> would grow over time too and it would develop the same problem.

        No, because the critical set is determined by the user (by setting
the socket flag).
        The receive side has some things marked as "critical" until we
have processed enough to check the socket flag, but then they should
be released. Those short-lived allocations and frees are more or less
0 net towards the pool.
        Certainly, it wouldn't work very well if every socket is
marked as "critical", but with an adequate pool for the workload, I
expect it'll work as advertised (esp. since it'll usually be only one
socket associated with swap management that'll be critical).

                                                                +-DLS
