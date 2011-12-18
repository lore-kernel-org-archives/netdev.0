From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: v6: faster tree-based sysctl implementation
Date: Sun, 18 Dec 2011 00:05:31 -0800
Message-ID: <m1fwgipano.fsf@fess.ebiederm.org>
References: <CAPLs8y9omncDbLE_KNoKOLLbfwHjWYUJX_i7cC4bLiJsyPbtZQ@mail.gmail.com>
	<m1obv9rkyp.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	Anca Emanuel <anca.emanuel@gmail.com>,
	Benjamin LaHaise <bcrl@kvack.org>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50541 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab1LRID6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 03:03:58 -0500
In-Reply-To: <m1obv9rkyp.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Fri, 16 Dec 2011 00:15:26 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I spent some time playing this and managed to get something that works
using proc_dir_entries.  And while it is simpler (600 less lines of
code) it takes about 3x the space of just what using ctl_table entries
does.

I managed to prove to myself that the current sysctl infrastructure
relies the union directory existence semantics pretty strongly.  Despite
all of Al's work to the contrary when he introduced attached_by and kin
in sysctl head.

One nice thing I managed to do was to shift around the problem a bit
so that only at /proc/sys/net do we to namespace weirdness.  Which also
considerably simplifies the problem.

Now that I know that normal unix directory semantics are a lost cause
removing the child entry from ctl_table looks like a very productive
exercise.  

Furthermore it feels like the optimal data structure would be a
directory tree that is created on demand as we create entries,
and a second copy of that directory tree that is per network namespace.

That is very similar to the data structure you wound up with.

So in the next little bit I am going to see if I can combine what
you did and what I did and see if I can come up with something that
is obvious in how it works from looking at it's data structures.

Eric
