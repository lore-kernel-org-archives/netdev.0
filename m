From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: [patch] e1000 TSO parameter
Date: Tue, 15 Jul 2003 23:32:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16148.61840.663255.863176@napali.hpl.hp.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229169@orsmsx402.jf.intel.com>
	<20030714214510.17e02a9f.davem@redhat.com>
	<16147.37268.946613.965075@napali.hpl.hp.com>
	<20030714223822.23b78f9b.davem@redhat.com>
	<16148.34787.633496.949441@napali.hpl.hp.com>
	<20030715183911.1c18cc15.davem@redhat.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, davidm@napali.hpl.hp.com, scott.feldman@intel.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030715183911.1c18cc15.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Tue, 15 Jul 2003 18:39:11 -0700, "David S. Miller" <davem@redhat.com> said:

  >>  We could, but would it always be a win?  Especially for
  >> copy_from_user().  Most of the time, that data remains cached, so
  >> I don't think we'd want to use non-temporal stores on those (in
  >> general).  csum_and_copy_from_user() isn't well optimized yet.
  >> Let's see if I can find a volunteer... ;-)

  DaveM> No, I mean "bypass L2 cache on miss" for stores.  Don't tell
  DaveM> me IA64 doesn't have that? 8) I certainly didn't mean "always
  DaveM> bypass L2 cache" for stores :-)

What I'm saying is that I almost always want copy_user() to put the
destination data in the cache, even if it isn't cached yet.  Many
copy_user() calls are for for data structures that easily fit in the
cache and the data is usually used quickly afterwards.

As for cache-hints supported by IA64: the architecture supports
various non-temporal hints (non-temporal in 1st, 2nd, or all
cache-levels).  How these hints are implemented depends on the chip.
On McKinley, non-temporal hints are generally implemented by storing
the data in the cache without updating the LRU info.  So if the data
is already there, it will stay cached (until a victim is needed).

	--david
