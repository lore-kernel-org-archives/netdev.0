From: Jim Gettys <jg@freedesktop.org>
Subject: Re: BQL crap and wireless
Date: Wed, 31 Aug 2011 09:28:14 -0400
Message-ID: <4E5E36EE.8080501@freedesktop.org>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com> <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com> <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com> <4E5C3B47.1050809@freedesktop.org> <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com> <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g@mail.gmail.com> <4E5CEC79.3090802@freedesktop.org> <9BB251C1-A211-486D-A717-59149AC3A709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Chadd <adrian@freebsd.org>,
	Tom Herbert <therbert@google.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: Andrew McGregor <andrewmcgr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:55494 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436Ab1HaN2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 09:28:18 -0400
In-Reply-To: <9BB251C1-A211-486D-A717-59149AC3A709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2011 05:47 PM, Andrew McGregor wrote:
> On 31/08/2011, at 1:58 AM, Jim Gettys wrote:
>
>> On 08/29/2011 11:42 PM, Adrian Chadd wrote:
>>> On 30 August 2011 11:34, Tom Herbert <therbert@google.com> wrote:
>>>
>>> C(P) is going to be quite variable - a full frame retransmit of a 4ms
>>> long aggregate frame is SUM(exponential backoff, grab the air,
>>> preamble, header, 4ms, etc. for each pass.)
>>>
>> It's not clear to me that doing heroic measures to compute the cost is
>> going to be worthwhile due to the rate at which the costs can change on
>> wireless; just getting into the rough ballpark may be enough. But
>> buffering algorithms and AQM algorithms are going to need an estimate of
>> the *time* it will take to transmit data, more than # of bytes or packets.
> That's not heroic measures; mac80211 needs all the code to calculate these times anyway, it's just a matter of collecting together some things we already know and calling the right function.
>
>

Fine; if it's easy, accurate is better (presuming the costs get
recalculated when circumstances change). We also will need the amount of
data being transmitted; it is the rate of transmission (the rate at
which the buffers are draining) that we'll likely need.

Here's what I've gleaned from reading "RED in a different light",  Van
Jacobson's Mitre talk and several conversations with Kathleen Nichols
and Van: AQM algorithms that can handle variable bandwidth environments
will need to be able to know the rate at which buffers empty.  It's the
direction they are going with their experiments on a "RED light" algorithm.

The fundamental insight as to why classic RED can't work in the wireless
environment is that the instantaneous queue length has little actual
information in it. Classic RED is tuned using the queue length as its
basic parameter.  Their belief as to algorithms that will work is that
the need to keep track of the running queue length *minimum over time*;
you want to keep the buffers small on a longer term basis (so they both
can absorb transients, which is their reason for existence, while
keeping the latency typically low).  The additional major challenge we
face that core routers do not is the highly variable traffic of mixed
mice and elephants.  What actually works only time will tell.

So in an environment in which the rate of transmission is highly
variable, such as wireless, or even possibly modern broadband with
PowerBoost, classic RED or similar algorithms that do not take the
buffer drain rate cannot possibly hack it properly.
                        - Jim
