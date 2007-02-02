From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] mm: fix page_mkclean_one
Date: Fri, 2 Feb 2007 16:08:35 +0300
Message-ID: <20070202130835.GA726@2ka.mipt.ru>
References: <1170369622.3453.72.camel@garangu> <45C2F98C.3070000@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Mark Groves <mjgroves@uwaterloo.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423046AbXBBNJz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <45C2F98C.3070000@yahoo.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 02, 2007 at 07:42:52PM +1100, Nick Piggin (nickpiggin@yahoo.com.au) wrote:
> Anyway, I had a look at your bugzilla test-case and managed to slim it
> down to something that easily shows what the problem is (available on
> request) -- the problem is that recipient of the sendfile is seeing
> modifications that occur to the source file _after_ the sender has
> completed the sendfile, because the file pages are not copied but
> queued.
> 
> I think the usual approach to what you are trying to do is to set TCP_CORK,
> then write(2) the header into the socket, then sendfile directly from the
> file you want.
> 
> Another approach I guess is to implement an ack in your userland protocol
> so you do not modify the sendfile source file until the client acks that
> it has all the data.

Mark, don't you use e1000 or other scatter-gather capable nic with
checksum offload? Likely yes.

Actual data sucking in that case happens when packet is supposed to be
transmitted by the NIC, not when sendfile() is returned. The same
applies to the case, when you have fancy egress filtering.

It is not allowed to modify pages until they are really transmitted, if
you want data integrity.

There are _no_ bugs in network or VFS cache in this test case.

> I'm not sure if there are any other usual ways to do this (ie. a barrier
> for sendfile, to ensure it will not pick up "future" modifications to the
> file). netdev cc'ed, someone there might have additional comments.
> 
> Please close this bug if/when you are satisfied it is not a kernel problem.
> 
> Thanks,
> Nick
> 
> -- 
> SUSE Labs, Novell Inc.
> Send instant messages to your online friends http://au.messenger.yahoo.com 

-- 
	Evgeniy Polyakov
