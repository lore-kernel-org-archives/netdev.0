From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 2 Jun 2008 14:53:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806021442450.16829@wrl-59.cs.helsinki.fi>
References: <E1K33OH-0005QX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, ray-lk@madrabbit.org, mingo@elte.hu,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759964AbYFBLx3@vger.kernel.org>
In-Reply-To: <E1K33OH-0005QX-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Jun 2008, Herbert Xu wrote:

> Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > Before:
> > tcp    65436      0 lo:5000          lo:59980         ESTABLISHED -
> 
> This is what happens before accept(2) is called.  Ingo, please
> strace the process that owns the listening socket to make sure
> that it is actually calling accept(2).  If it ever stops calling
> accept(2) then this is expected behaviour.

Shouldn't that be already visible in the ingo's sysrq-t dump, no? There:

  http://marc.info/?l=linux-kernel&m=121182099131520&w=2

There are many sys_accepts at least (if I understand that dump at all). 
There were some ip_local_outs there as well, which made me wonder if the 
totally innocent looking commit 1ac06e0306d0192a7a4d9ea1c9e06d355ce7e7d3 
(ipsec: Use the correct ip_local_out function) has something to do with 
this (I definately don't understand that part at all).

-- 
 i.
