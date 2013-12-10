From: ajay seshadri <seshajay@gmail.com>
Subject: Re: Fwd: UDP/IPv6 performance issue
Date: Tue, 10 Dec 2013 17:25:52 -0500
Message-ID: <CAGA2gK6-9QednGxrPr_zrTHYm4W6t7yrrBOSNitujTMLibuOww@mail.gmail.com>
References: <CAGA2gK6rf8E7cCO=RwbdFAt2ucfxUbCjqhVoga9cnHrEKxcp9g@mail.gmail.com>
	<CAGA2gK5gfdaKeQWzT4Dd45AhavD4pYaCVyayf7Hd+q5pPUjfKQ@mail.gmail.com>
	<52A749CB.1010909@hp.com>
	<52A74E32.4040900@hp.com>
	<CAGA2gK7tjQZ6sq1qqTua_J0uY47Dq7h-vWR=c_LQReq3Rwc=_Q@mail.gmail.com>
	<52A78809.4020103@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:53222 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236Ab3LJWZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 17:25:53 -0500
Received: by mail-ig0-f171.google.com with SMTP id c10so2875813igq.4
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 14:25:52 -0800 (PST)
In-Reply-To: <52A78809.4020103@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rick,

On Tue, Dec 10, 2013 at 4:30 PM, Rick Jones <rick.jones2@hp.com> wrote:

> I mean how many instructions/cycles it takes to send/receive a single
> packet, where all the costs are the per-packet costs and the per-byte costs
> are kept at a minimum.  And also where the stateless offloads won't matter.
> That way whether a stateless offload is enabled for one protocol or another
> is essentially a don't care.

Given below are the results for tests you recommended:
IPv6:

MIGRATED UDP REQUEST/RESPONSE TEST from ::0 (::) port 0 AF_INET6 to
1111::80 () port 0 AF_INET6 : first burst 0
Local /Remote
Socket        Size        Request Resp. Elapsed Trans.     CPU    CPU
  S.dem   S.dem
Send          Recv       Size        Size   Time       Rate
local  remote local   remote
bytes          bytes       bytes     bytes  secs.      per sec   % S
 % S    us/Tr   us/Tr

10485760 10485760 1            1        10.00   16977.61   5.12   5.46
  24.138  25.721
10485760 10485760

IPv4:

MIGRATED UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0
AF_INET to 192.168.31.80 () port 0 AF_INET : first burst 0
Local /Remote
Socket       Size          Request Resp.  Elapsed Trans.       CPU
CPU    S.dem   S.dem
Send         Recv         Size       Size     Time      Rate
local  remote local   remote
bytes         bytes        bytes      bytes  secs.      per sec      %
S    % S    us/Tr   us/Tr

10485760 10485760  1            1        10.00      20414.38   5.24
4.70   20.522  18.417
10485760 10485760

The transaction rate for IPv6 is less.


> So, single-byte _RR since it is sending only one byte at a time will
> effectively "bypass" the offloads.  I use it as something of a proxy for
> those things that aren't blasting great quantities of data.

With no segmentation offload, I was treating the CPU as a known
bottleneck in both the cases and trying to do an apples to apples
comparison between UDP IPv4 and IPv6 performance. As we take a 15 -
20% performance hit for IPv6, I was trying to understand why the ipv6
route cache gc functions showed up in the profile, which was a bit
surprising.


> I presume you are looking at the receive throughput and not the reported
> send side throughput right?

I am looking at the bytes received. In fact the two are identical as
the network no longer is the bottleneck and we are pegged by the CPU
on the sender for 1500 byte packets.

Thanks,
Ajay
