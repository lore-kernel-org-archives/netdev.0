From: "Piotr Sawuk" <a9702387@unet.univie.ac.at>
Subject: Re: resurrecting tcphealth
Date: Sun, 15 Jul 2012 01:43:18 +0200
Message-ID: <b93cddfd0a19158ec59823140d1e2075.squirrel@webmail.univie.ac.at>
References: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
    <20120714144800.7f8c97f6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from grace.univie.ac.at ([131.130.3.115]:58192 "EHLO
	grace.univie.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031Ab2GNXnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 19:43:21 -0400
In-Reply-To: <20120714144800.7f8c97f6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sa, 14.07.2012, 23:48, Stephen Hemminger wrote:
> Maybe it would be better to use netlink info (for ss command)
> rather than a /proc/net interface.
> See how existing TCP values and MEMINFO are handled.
>

I'm confused, what exactly do you mean?
of course a library-interface might be more interesting than proc/net.
the proc/net/tcphealth functionality probably could be done in userspace,
although I'm wondering how userspace could traverse all tcp_sock structures
for all clients -- but the gain would be a bit more security. and the rest
of the patch still would need to stay in the kernel since that info it
collects would otherwise be lost completely. so I somehow doubt this would
be worth the effort. better would be optional tcphealth disabled by default
for security-reasons. (i.e. if you're a server you don't want to enable it.)

@"David Miller":
sorry, I forgot an important info about this patch, an info that can be
found in the paper I quoted:

'We concentrate on client side metrics to make our results more applicable
to web clients. We chose this strategy to help answer the often asked
question: "Why is my Internet connection so slow?"
...
Since we only have access to the client node and not the server, we must
find performance data using only the information coming downstream to us.
Savage showed that the TCP protocol maintains data that we can leverage to
our advantage and we use that idea to monitor per-connection TCP health at
the client. This task is made difficult because of the TCP philosophy of
"smart sender, dumb receiver". There is simply more information about the
connection on the server side than on the client.' [1]

tcp_info is such a server-side diagnosis, clients usually don't send enough
data to make the info therein meaningful for checking the "health" of tcp.
it's all about the senders, and the desktop-pc simply isn't that big of a
tcp-sender to slashdot and co.

@"Eric Dumazet":
the same goes for you too. netstat -s and whatever kind of pooling together
statistics on all internet-connections is useful for a server-admin only,
slowness of particular sites can only be investigated with ping and this
tcphealth patch when you're on client-side.

as for userspace-tools, apart from tcp-health display in each
downloading-progress-bar I can think of cron-jobs which wait for better
tcp-health before spidering some site, or an altered wget in mirror-mode.
the gkrellm-plugin that comes with this patch might count together all the
data of tcphealth, but when a tcp_sock isn't stored anymore that data is
forgotten and you get a concurrent info most likely for only one site, since
the client wont have much connections open and will be closing old
connections frequently.

oh, and again I recommend the really short although outdated thesis

[1] https://sacerdoti.org/tcphealth/tcphealth-paper.pdf
