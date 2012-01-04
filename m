From: Mihai Maruseac <mihai.maruseac@gmail.com>
Subject: Re: [PATCH] ipv6/addrconf: speedup /proc/net/if_inet6 filling
Date: Wed, 4 Jan 2012 19:03:53 +0200
Message-ID: <CAOMsUMKp_7w2+0bBTFbQk3HKpobJQd8b2vi6_zTTzGjtZ_+OMA@mail.gmail.com>
References: <1325669495-5626-1-git-send-email-mmaruseac@ixiacom.com> <20120104082200.437df26a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Mihai Maruseac <mmaruseac@ixiacom.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49667 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756448Ab2ADREO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 12:04:14 -0500
Received: by ggdk6 with SMTP id k6so10364553ggd.19
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 09:04:13 -0800 (PST)
In-Reply-To: <20120104082200.437df26a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2012 at 6:22 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Wed, =A04 Jan 2012 11:31:35 +0200
> Mihai Maruseac <mihai.maruseac@gmail.com> wrote:
>
>> This ensures a linear behaviour when filling /proc/net/if_inet6 thus=
 making
>> ifconfig run really fast on IPv6 only addresses. In fact, with this =
patch and
>> the IPv4 one sent a while ago, ifconfig will run in linear time rega=
rdless of
>> address type.
>>
>> IPv4 related patch: f04565ddf52e401880f8ba51de0dff8ba51c99fd
>> =A0 =A0 =A0 =A0dev: use name hash for dev_seq_ops
>> =A0 =A0 =A0 =A0...
>>
>> Some statistics (running ifconfig > /dev/null on a different setup):
>>
>> iface count / IPv6 no-patch time / IPv6 patched time / IPv4 time
>> ----------------------------------------------------------------
>> =A0 =A0 =A0 6250 =A0| =A0 =A0 =A0 0.23 s =A0 =A0 =A0 | =A0 =A0 =A00.=
13 s =A0 =A0 =A0 | =A00.11 s
>> =A0 =A0 =A012500 =A0| =A0 =A0 =A0 0.62 s =A0 =A0 =A0 | =A0 =A0 =A00.=
28 s =A0 =A0 =A0 | =A00.22 s
>> =A0 =A0 =A025000 =A0| =A0 =A0 =A0 2.91 s =A0 =A0 =A0 | =A0 =A0 =A00.=
57 s =A0 =A0 =A0 | =A00.46 s
>> =A0 =A0 =A050000 =A0| =A0 =A0 =A011.37 s =A0 =A0 =A0 | =A0 =A0 =A01.=
21 s =A0 =A0 =A0 | =A00.94 s
>> =A0 =A0 128000 =A0| =A0 =A0 =A086.78 s =A0 =A0 =A0 | =A0 =A0 =A03.05=
 s =A0 =A0 =A0 | =A02.54 s
>>
>> Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
>> Cc: Daniel Baluta <dbaluta@ixiacom.com>
>> ---
>> =A0net/ipv6/addrconf.c | =A0 43 ++++++++++++++++++++++++++++--------=
-------
>> =A01 files changed, 28 insertions(+), 15 deletions(-)
>>
>
>
> What about netlink? Also ifconfig is really considered deprecated,
> especially for ipv6 usage.

Yes, ifconfig is deprecated but the /proc/net/if_inet6 file can be
used in a lot of bash scripts and this was what we wanted to optimize.

We tried to look at the netlink sockets used in iproute2 but there
seems to be no way to improve the performance there. We used 3 pair of
eyes for this before giving up.

I'll come back with statistics from ip a s in at most 24 hours, I
cannot test right now.

Thanks,
Mihai
