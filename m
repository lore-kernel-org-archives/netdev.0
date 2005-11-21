From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink nlmsg_pid supposed to be pid or tid?
Date: Tue, 22 Nov 2005 09:15:03 +1100
Message-ID: <E1EeJwF-0006wc-00@gondolin.me.apana.org.au>
References: <4382406D.1040508@nortel.com>
Cc: kuznet@ms2.inr.ac.ru, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751163AbVKUWPX@vger.kernel.org>
To: cfriesen@nortel.com (Christopher Friesen)
In-Reply-To: <4382406D.1040508@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christopher Friesen <cfriesen@nortel.com> wrote:
> 
> When an NPTL child thread uses getpid() to specify the pid, it never 
> receives a response to this request.  Running the same code on the 
> parent works, and running the same code under Linuxthreads works.

As I said before, you should not rely on getpid() to work.  Any other
process in the system can bind to your pid which makes it unavailable
to your process.  In which case the kernel will pick an arbitrary
negative pid as your address.

You should always use getsockaddr(2) to get your local address.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
