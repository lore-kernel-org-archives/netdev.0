From: Andreas Schuldei <schuldei@spotify.com>
Subject: Re: ipsec performance
Date: Wed, 30 Dec 2009 00:31:08 +0100
Message-ID: <f5327b860912291531u31bf0719t4c031fa14bfe7003@mail.gmail.com>
References: <f5327b860912291309g701d6345k6517a4eb75830faf@mail.gmail.com>
	 <88cc3e770912291455w240d543atadbcbdd22746c@mail.gmail.com>
Reply-To: schuldei@spotify.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Abhijit Karmarkar <awk@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:44967 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbZL2XbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 18:31:10 -0500
Received: by fxm25 with SMTP id 25so5624571fxm.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 15:31:08 -0800 (PST)
In-Reply-To: <88cc3e770912291455w240d543atadbcbdd22746c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 11:55 PM, Abhijit Karmarkar <awk@google.com> wrote:
> On Tue, Dec 29, 2009 at 1:09 PM, Andreas Schuldei <schuldei@spotify.com> wrote:
>> hi!
>>
>> i experience performance issues with ipsec transport mode with debian
>> lenny and strongswan, on a stock debian kernel 2.6.26-2-amd64.
>>
>> the goal is to set up a full mash of several hundred hosts, talking
>> ipsec with each other, in order to be able to skip firewalls and to be
>> able to let the hosts be spread out over several sites in a
>> transparent fashion.
>>
>> regardless of the cipher (i tried aes and blowfish) the bandwidth
>> maxes out at about 0.5-0.25 of the expected (unencrypted) value,
>> without hitting obvious bottlenecks like cpu, disk, or ram.
>
> you may want try Steffen Klassert's parallel crypto patches (nice work!):
>
>  http://marc.info/?l=linux-kernel&m=126155699817914&w=2
>
> the numbers are impressive. i plan to try them sometime this (or next week).
>
> yes, on the current kernels, the ipsec throughput numbers are around
> 50% of the non-ipsec case. for me.

i have an 8core xeon machine 2.5GHz machine and my throughput of
39Mbyte/s correlates nicely with Steffens 325Mbit/s when i use AES.
when i switch to blowfish the throuput decreases to 27.5Mbyte/s. the
time the cpu spends in kernel code decreases, too, to ~5% (give or
take a coconut). the machine seems idle, almost. where is the
bottleneck? what needs parallelization? (i read steffens mail but i
didnt understand his explanation. could you explain it in laymens
terms?) what i find funny is that the apache process serving the data
uses between 20-95%cpu. how come?

i dont intent do have vpn gateways.  I want every machine to encrypt
its own network traffic. doubling the performance (as steffens patch
seems to do) would help (in the AES case, not for blowfish.). i would
want to actually deploy the stuff soon, though, and i will have a hard
time selling a patch and a homebuild kernel to my colleges.

>> how can i inspect window size, fragmentation etc? are there useful
>> files in /proc or /sys or enlightening ip commands?

is there a way to do this?
