From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Fri, 15 Apr 2016 08:42:41 -0400
Message-ID: <5710E1C1.2090209@mojatatu.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160414151813.GE3715@orbyte.nwl.cc>
 <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-04-14 01:49 PM, Eric Dumazet wrote:

> And what would be the chosen behavior ?
>

TBF is probably a bad example because it started life as
a classless qdisc. There was only one built-in fifo queue
that was shaped. Then someone made it classful and changed
this behavior. To me it sounds reasonable to have the
default behavior restored. At minimal consistency.

> Relying on TBF installing a bfifo for you at delete would be hazardous.
>
> For example CBQ got it differently than HFSC
>
> If qdisc_create_dflt() fails in CBQ, we fail the 'delete', while HFSC
> falls back to noop_qdisc, without warning the user :(
>
> At least always using noop_qdisc is consistent. No magic there.
>
> Doing 'unification' right now would break existing scripts.
>
> This is too late, I am afraid.


Sigh. So rant:
IMO, we should let any new APIs and API updates stay longer
in discussion. Or better mark them as unstable for sometime.
The excuse that "it is out in the wild therefore cant be changed"
is harmful because the timeline is "forever" whereas
patches are applied after a short period of posting
and discussions and sometimes not involving the right people.
It is like having a jury issuing a death sentence after 1 week of
deliberation. You cant take it back after execution.

cheers,
jamal
