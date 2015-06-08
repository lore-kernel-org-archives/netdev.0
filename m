From: Joe Stringer <joestringer@nicira.com>
Subject: Re: "ip netns create" hangs forever, spamming console with
 "unregister_netdevice: waiting for lo to become free"
Date: Sun, 7 Jun 2015 20:56:53 -0700
Message-ID: <CANr6G5zVPaP1N-9rQ=PCn9-NJGd7QONmv_HO6OqJs19yBWCyFA@mail.gmail.com>
References: <CAKCAbMgkpFMX7cQS=c3eD802aKTWesCv1TW7n8mtBvqLF0BN8Q@mail.gmail.com>
 <CAKCAbMj9tKg95mNyUQZxRHxtTTCb2BQxYLehtA8XjD7Sf_t1Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Zack Weinberg <zackw@panix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:52644 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750815AbbFHEED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 00:04:03 -0400
Received: by yhpn97 with SMTP id n97so35653726yhp.0
        for <netdev@vger.kernel.org>; Sun, 07 Jun 2015 21:04:02 -0700 (PDT)
In-Reply-To: <CAKCAbMj9tKg95mNyUQZxRHxtTTCb2BQxYLehtA8XjD7Sf_t1Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 May 2015 at 11:56, Zack Weinberg <zackw@panix.com> wrote:
> On Tue, May 26, 2015 at 12:21 PM, Zack Weinberg <zackw@panix.com> wrote:
>> I have an application that makes heavy use of network namespaces,
>> creating and destroying them on the fly during operation.  With 100%
>> reproducibility, the first invocation of "ip netns create" after any
>> "ip netns del" hangs forever in D-state; only rebooting the machine
>> clears the condition.
>
> Following up to myself to say that reproduction is not as simple as
> 'ip netns add test; ip netns del test; ip netns add test2'.  In fact,
> not even bringing the namespace (and all associated interfaces) up and
> then  down again _exactly_ as my production code does it will trigger
> the bug.  It appears to be necessary to push a significant amount of
> data through interfaces attached to the namespace.
>
> Since I had to reset the machine to attempt to create a repro recipe,
> I can no longer perform diagnostics on the hung processes, but I've
> restarted the application and it should reach the problem state again
> in a day or two.

Hi Zack, have you had any further development on this issue?

We've been running into a similar issue during OVS development where
in a fairly complex environment running tests using ovs with tunnels
and conntrack inside docker containers reliably produces very similar
lockdep reports. At face value, it seems like something grabs the net
mutex and doesn't let go. The problem only arises after sending
traffic between containers. I'm trying to reduce the possibilities in
this test case to get better information on when/how it fails.
