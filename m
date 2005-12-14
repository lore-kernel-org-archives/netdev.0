From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC][PATCH 3/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 19:33:49 +0100
Message-ID: <200512141933.49684.netdev@axxeo.de>
References: <Pine.LNX.4.58.0512140052470.31720@w-sridhar.beaverton.ibm.com> <1134559039.25663.12.camel@localhost.localdomain> <1134583896.8698.33.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964861AbVLNSdg@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1134583896.8698.33.camel@w-sridhar2.beaverton.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> The only reason i made these macros is that i would expect this to a compile
> time configurable option so that there is zero overhead for regular users.
> 
> #ifdef CONFIG_CRIT_SOCKET
> #define SK_CRIT_ALLOC(sk, flags) ((sk->sk_allocation & __GFP_CRITICAL) | flags)
> #define CRIT_ALLOC(flags) (__GFP_CRITICAL | flags)
> #else
> #define SK_CRIT_ALLOC(sk, flags) flags
> #define CRIT_ALLOC(flags) flags
> #endif

Oh, that's much simpler to achieve:

#ifdef CONFIG_CRIT_SOCKET
#define __GFP_CRITICAL_SOCKET __GFP_CRITICAL
#else
#define __GFP_CRITICAL_SOCKET 0
#endif

Maybe we can get better naming here, but you get the point, I think.


Regards

Ingo Oeser
