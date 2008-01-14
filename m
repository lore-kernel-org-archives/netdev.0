From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 14 Jan 2008 17:56:28 +0100
Message-ID: <478B943C.7080009@cosmosbay.com>
References: <478654C3.60806@nortel.com> <2c0942db0801112137k3f3f885ek212d5cbaecb7fea0@mail.gmail.com> <478B8473.6080506@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ray Lee <ray-lk@madrabbit.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.18]:3012 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531AbYANQ4g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 11:56:36 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf1927.orange.fr (SMTP Server) with ESMTP id 19CFC1C00126
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 17:56:33 +0100 (CET)
In-Reply-To: <478B8473.6080506@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen a =C3=A9crit :
> Ray Lee wrote:
>> On Jan 10, 2008 9:24 AM, Chris Friesen <cfriesen@nortel.com> wrote:
>
>>> After a recent userspace app change, we've started seeing packets b=
eing
>>> dropped by the ethernet hardware (e1000, NAPI is enabled).  The
>>> error/dropped/fifo counts are going up in ethtool:
>
>> Can you reproduce it with a simple userspace cpu hog? (Two, really,
>> one per cpu.)
>> Can you reproduce it with the newer e1000?
>
> Hmm...good questions and I haven't checked either.  The first one is=20
> relatively straightforward.  The second is a bit trickier...last time=
=20
> I tried the latest e1000 driver the card wouldn't boot (we use netboo=
t).
>
>> Can you reproduce it with git head?
>
> Unfortunately, I don't think I'll be able to try this.  We require=20
> kernel mods for our userspace to run, and I doubt I'd be able to get=20
> the time to port all the changes forward to git head.
>
>> If the answer to the first one is yes, the last no, then bisect unti=
l
>> you get a kernel that doesn't show the problem. Backport the fix,
>> unless the fix happens to be CFS. However, I suspect that your
>> userpace app is just starving the system from time to time.
>
> It's conceivable that userspace is starving the kernel, but we have d=
o=20
> about 45% idle on one cpu, and 7-10% idle on the other.
>
> We also have an odd situation where on an initial test run after=20
> bootup we have 18-24% idle on cpu1, but resetting the test tool drops=
=20
> that to the 7-10% I mentioned above.
>
> Based on profiling and instrumentation it seems like the cost of=20
> sctp_endpoint_lookup_assoc() more than triples, which means that the=20
> amount of time that bottom halves are disabled in that function also=20
> triples.
Any idea of the size of sctp hash size you have ?
(your dmesg probably includes a message starting with SCTP: Hash tables=
=20
configured...=20

How many concurrent sctp sockets are handled ?

Maybe sctp_assoc_hashfn() is too weak for your use, and some chains are=
=20
*really* long.




