From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 12:10:22 +0100
Message-ID: <200702201210.22907.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220.021209.39159087.davem@davemloft.net> <20070220103014.GB7237@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39342 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932879AbXBTLKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 06:10:32 -0500
In-Reply-To: <20070220103014.GB7237@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 11:30, Evgeniy Polyakov wrote:
> On Tue, Feb 20, 2007 at 02:12:09AM -0800, David Miller (davem@davemloft.net) 
wrote:
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Tue, 20 Feb 2007 11:04:15 +0100
> >
> > > Using a jenkin's hash permits a better hash distribution for a litle
> > > cpu cost.  I will post later a distribution simulation based on the
> > > data gathered from the same real server.
> >
> > Actually someone (I think it was Evgeniy in fact) made such
> > comparisons and found in his studies that not only does the current
> > ehash xor hash function distribute about as well as jenkins, it's
> > significantly cheaper to calculate :-)
>
> Yep, it happend to be my tests :)
> Jenkins hash was slower and had significant artifacts for some usage
> cases ended up with extremely long chain length.
> One can find more details at
> http://tservice.net.ru/~s0mbre/blog/2006/05/14#2006_05_14
> http://tservice.net.ru/~s0mbre/blog/2006/06/01#2006_06_01

Please explain why you chose    h = jhash_2words(faddr, laddr, ports);
        h ^= h >> 16;
        h ^= h >> 8;

jhash is very good, no need to try to be smarter, shufling some bytes... and 
adding artifacts.

