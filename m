From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] netfilter: replace horrible hack with ksize()
Date: Thu, 6 Mar 2008 16:14:23 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803061612290.4202@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
 <47CFF9B7.5060803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, clameter@sgi.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47CFF9B7.5060803@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

On Thu, 6 Mar 2008, Patrick McHardy wrote:
> > @@ -95,7 +85,7 @@ void *__nf_ct_ext_add(struct nf_conn *ct
> >   newlen = newoff + t->len;
> >   rcu_read_unlock();
> > 
> > -	if (newlen >= ct->ext->real_len) {
> > +	if (newlen >= ksize(ct->ext)) {
> 
> This needs to look at the currently allocated size, otherwise
> it will always realloc when adding new extensions after having
> used up ksize(ct->ext) space.

Lets say you

  p = kmalloc(8, ...);

Then ksize(p) will return the currently allocated size which is 32 bytes 
when page size is 4 KB, and not 8 bytes. So it should be equivalent of 
what the current code does.

What am I missing here?

			Pekka
