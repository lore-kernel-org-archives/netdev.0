From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP congestion graphs
Date: Wed, 25 Oct 2006 18:30:25 -0700
Message-ID: <20061025183025.7c4f9d66@localhost.localdomain>
References: <20061025110207.78d38779@freekitty>
	<000701c6f885$b57aa390$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Sangtae Ha" <sha2@ncsu.edu>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37776 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965260AbWJZBam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 21:30:42 -0400
To: "Injong Rhee" <rhee@eos.ncsu.edu>
In-Reply-To: <000701c6f885$b57aa390$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Oct 2006 18:34:17 -0400
"Injong Rhee" <rhee@eos.ncsu.edu> wrote:

> Not sure why the slow start for cubic is slower than the others.
> We will check on this.
> 

I think it is because cubic initializes with a ssthresh of 100,
and others leave ssthresh uninitialized until the first loss.
This causes cubic to change to conservative mode once it crosses
the initial ssthresh.  Other protocols just keep doing additive
increase.

My large BDP test has a 500ms delay (250ms each way) and a real
100mbit link on the last hop.
Because the intermediate emulator has a large queue (10,000 packets)
large growth is possible before the first loss event. There were also
no other flows during this test to fill the intermediate queue.

This may very well be a bogus test, I just was looking for large
BDP behavior quirks. Any test without background traffic as you
have argued is unrealistic.
