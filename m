From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] e1000 TSO parameter
Date: Tue, 15 Jul 2003 23:30:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030715233034.31bf0709.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229169@orsmsx402.jf.intel.com>
	<20030714214510.17e02a9f.davem@redhat.com>
	<16147.37268.946613.965075@napali.hpl.hp.com>
	<20030714223822.23b78f9b.davem@redhat.com>
	<16148.34787.633496.949441@napali.hpl.hp.com>
	<20030715183911.1c18cc15.davem@redhat.com>
	<16148.61840.663255.863176@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidm@napali.hpl.hp.com, scott.feldman@intel.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <16148.61840.663255.863176@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003 23:32:48 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

>   DaveM> No, I mean "bypass L2 cache on miss" for stores.  Don't tell
>   DaveM> me IA64 doesn't have that? 8) I certainly didn't mean "always
>   DaveM> bypass L2 cache" for stores :-)
> 
> What I'm saying is that I almost always want copy_user() to put the
> destination data in the cache, even if it isn't cached yet.

No you don't :-)

If you miss, you do a bypass to main memory.  Then when the
app asks for the data (if it even does at all, consider that)
it get's a clean copy in it's L2 cache.

Overall it's more efficient this way.

> Many copy_user() calls are for for data structures that
> easily fit in the cache and the data is usually used quickly afterwards.

Absolutely correct.  We can't use the cache bypass-on-miss stores on
sparc64 unless the copy is at least a couple of cachelines in size.

It all works out, don't worry :-)
