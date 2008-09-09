From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 9 Sep 2008 10:00:29 -0300
Message-ID: <20080909130029.GA12726@ghostprotocols.net>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com> <48C6052D.2080203@redhat.com> <20080908.221742.02572583.davem@davemloft.net> <48C60FFC.8090109@redhat.com> <20080909062208.GB30385@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Snook <csnook@redhat.com>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45793 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756285AbYIINKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 09:10:33 -0400
Content-Disposition: inline
In-Reply-To: <20080909062208.GB30385@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 09, 2008 at 10:22:08AM +0400, Evgeniy Polyakov escreveu:
> Hi.
> 
> On Tue, Sep 09, 2008 at 01:56:12AM -0400, Chris Snook (csnook@redhat.com) wrote:
> > The easiest way to see the problem is to open a TCP socket to an echo 
> > daemon on loopback, make a bunch of small writes totaling less than your 
> > loopback MTU (accounting for overhead), and see how long it takes to get 
> > your echoes.  You can probably do this with netcat, though I haven't 
> > tried.  People don't expect loopback to have 40 ms latency when the box 
> > is lightly loaded, so they'd really like to tweak that down when it's 
> > hurting them.
> 
> Isn't Nagle without corking a very bad idea? Or you can not change the
> application?

In one such case, finantial app building logical packets via several
small buffer send calls I got it working with a "autocorking" LD_PRELOAD
library, libautocork:

http://git.kernel.org/?p=linux/kernel/git/acme/libautocork.git

git://git.kernel.org/pub/scm/linux/kernel/git/acme/libautocork.git

Details/test cases:

http://git.kernel.org/?p=linux/kernel/git/acme/libautocork.git;a=blob_plain;f=tcp_nodelay.txt

How to use it, what you get from using it:

http://git.kernel.org/?p=linux/kernel/git/acme/libautocork.git;a=blob_plain;f=libautocork.txt

- Arnaldo
