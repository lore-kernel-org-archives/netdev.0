From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Increasing TCP initial cwnd
Date: Tue, 27 Oct 2009 09:38:55 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0910270925210.28036@melkinkari.cs.Helsinki.FI>
References: <fa3cddca0910260640s22d0396ey5fc51c51047bc2c@mail.gmail.com>
 <alpine.DEB.2.00.0910261553180.19761@wel-95.cs.helsinki.fi>
 <fa3cddca0910260728n61d8de61p9e58260c893d9f9f@mail.gmail.com>
 <alpine.DEB.2.00.0910261629040.19761@wel-95.cs.helsinki.fi>
 <fa3cddca0910260807q714a24fdp1ffae601bb6f67ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Yair Gottdenker <yairgott@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48107 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755447AbZJ0Hiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 03:38:52 -0400
In-Reply-To: <fa3cddca0910260807q714a24fdp1ffae601bb6f67ba@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Oct 2009, Yair Gottdenker wrote:

> I already had a look in it. Their changes that are related to changing
> the initial cwnd  (snd_cwnd) are in several places in the patch:

Right. I know what I've modified in that patch... ;-)

> 1. tcp_ipv4.c in function tcp_init_cwnd. since currently I am working
> with no metric this is irrelevant.

You managed to mix up this filename twice in a row in a different way :-). 
...That function resides in tcp_input.c instead. And changes in 
tcp_init_metrics are not completely irrelevant, even with no metrics it 
is executed as "no metrics" works a bit differenctly than you seem to 
think.

> 2. tcp_ipv4.c: in function tcp_v4_init_sock, which I applied
> 3. tcp_minisocks.c - which I applied
> . They patched kernel 2.6.18.8 which is very old and there were a lot
> of changes since that in the kernel tcp layer. I didn't test their
> patch but applying the same logic to 2.6.31.3 doesn't seems to change
> initial window size.
> 
> It is clear that in order to correctly make the change to the initial
> cwnd, one should apply changes to many more scenarios like setting the
> initial cwnd after idle time and more. I want to proceed step by step,
> first the naive changes to make it work.

Hmm, it now rings a bell... You cannot directly set initial window to a 
large value (or you can but that doesn't do anything on the wire) because 
you hit first the limit of receiver advertised window that applies 
auto-tuning (with a starting value was four IIRC).

-- 
 i.
