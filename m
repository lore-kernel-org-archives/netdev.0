From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Sat, 4 Jan 2014 21:55:51 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401042143330.1598@ja.home.ssi.bg>
References: <20131219144816.33310@gmx.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1320584235-1388865352=:1598"
Cc: netdev@vger.kernel.org
To: Bob Falken <NetFestivalHaveFun@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44798 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752977AbaADTz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 14:55:59 -0500
In-Reply-To: <20131219144816.33310@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1320584235-1388865352=:1598
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Thu, 19 Dec 2013, Bob Falken wrote:

> Hello, I have an issue after kernel 2.6.37 and above.
> If i roll back to kernel 2.6.36.4 everything is fine.
> if recive more than 4294967295 multicast packets, the kernel does not register the multicast packets. and multicast routing does not functioning.

...

> I think there might be a variable in the kernel that get overflown. though i cannot be sure as im not a programmer. 
> 
> Let me know if you need more debug information.
> 
> Please help.  

	As Hannes guessed, may be it is really the missing
flags = FIB_LOOKUP_NOREF in ipmr_fib_lookup() when calling
fib_rules_lookup(), we have an atomic_inc_not_zero() there that
can stop to work after 4G lookups when rule's refcnt reaches 0.
As result, fib_rules_lookup() can start to return -ESRCH.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1320584235-1388865352=:1598--
