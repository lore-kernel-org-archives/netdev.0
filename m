From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Fri, 15 Apr 2016 07:58:48 -0700
Message-ID: <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
	 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160414151813.GE3715@orbyte.nwl.cc>
	 <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
	 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5710E1C1.2090209@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jikos@kernel.org>, Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5710E1C1.2090209@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-04-15 at 08:42 -0400, Jamal Hadi Salim wrote:
> On 16-04-14 01:49 PM, Eric Dumazet wrote:
> 
> > And what would be the chosen behavior ?
> >
> 
> TBF is probably a bad example because it started life as
> a classless qdisc. There was only one built-in fifo queue
> that was shaped. Then someone made it classful and changed
> this behavior. To me it sounds reasonable to have the
> default behavior restored. At minimal consistency.


Then you need to save the initial qdisc (bfifo for TBF) in a special
place, to make sure the delete operation is guaranteed to succeed.

Or fail the delete if the bfifo can not be allocated.

I can tell that determinism if far more interesting than usability for
some users occasionally playing with tc.

Surely the silent fallback to noop_qdisc is wrong.

Anyway, we probably need to improve our ability to understand qdisc
hierarchies. Having some hidden qdiscs is the real problem here.

We need to add some hash table so that qdisc_match_from_root() does not
have to scan hundred of qdiscs.
