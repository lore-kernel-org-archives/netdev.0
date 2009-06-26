From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Thu, 25 Jun 2009 19:11:41 -0700 (PDT)
Message-ID: <20090625.191141.261414015.davem@davemloft.net>
References: <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com>
	<4A442B65.8040701@gmail.com>
	<alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, oleg@redhat.com, jolsa@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, htejun@gmail.com
To: davidel@xmailserver.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756773AbZFZCLr@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Davide Libenzi <davidel@xmailserver.org>
Date: Thu, 25 Jun 2009 19:04:04 -0700 (PDT)

> On Fri, 26 Jun 2009, Eric Dumazet wrote:
> 
>> Adding a plain smp_mb() in tcp_poll() for example would slowdown select()/poll() with NULL
>> timeout.
> 
> Do you think of it as good design adding an MB on a subsystem, because of 
> the special locking logic of another one?
> The (eventual) slowdown, IMO can be argued sideways, by saying that 
> non-socket users will pay the price for their polls.

Perhaps every performance argument is moot since spin_unlock() used to
have the barrier :-)
