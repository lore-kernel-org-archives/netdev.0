From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Tue, 14 Aug 2007 16:14:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708141612590.693@schroedinger.engr.sgi.com>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2350A.1010807@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Satyam Sharma <satyam@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761742AbXHNXOk@vger.kernel.org>
In-Reply-To: <46C2350A.1010807@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Aug 2007, Chris Snook wrote:

> Because atomic operations are generally used for synchronization, which
> requires volatile behavior.  Most such codepaths currently use an inefficient
> barrier().  Some forget to and we get bugs, because people assume that
> atomic_read() actually reads something, and atomic_write() actually writes
> something.  Worse, these are architecture-specific, even compiler
> version-specific bugs that are often difficult to track down.

Looks like we need to have lock and unlock semantics?

atomic_read()

which has no barrier or volatile implications.

atomic_read_for_lock

	Acquire semantics?


atomic_read_for_unlock

	Release semantics?
