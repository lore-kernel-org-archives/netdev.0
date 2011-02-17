From: Ben Greear <greearb@candelatech.com>
Subject: Re: Read sent/received bytes -- without opening a file in /sys or
 /proc
Date: Thu, 17 Feb 2011 09:32:55 -0800
Message-ID: <4D5D5BC7.50802@candelatech.com>
References: <4D5CFF19.6050400@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan-Philip gehrcke <jgehrcke@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36364 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab1BQRc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 12:32:59 -0500
In-Reply-To: <4D5CFF19.6050400@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2011 02:57 AM, Jan-Philip gehrcke wrote:
> Dear list,
>
> I'm about to write a small C program for measurements of the bandwidth
> on some network interface of my home router (uname -a: Linux
> fritz.fonwlan.box 2.6.19.2 #2 Thu Nov 18 16:35:17 CET 2010 mips
> GNU/Linux). I would like to accomplish very *precise* results, while
> keeping the absolute measurement time low.
>
> In general, this problem requires the knowledge of time and byte
> differences. Therefore, two time measurements and two byte counter
> measurements for each, received and sent bytes, are required. Currently,
> I am measuring time via
>
>      clock_gettime(CLOCK_MONOTONIC, ...)
>
> and reading the byte counters by reading files in sysfs, e.g.
>
>       /sys/class/net/${interface}/statistics/rx_bytes.
>
> This is very easy and works well, but reading these files four times
> takes some (varying) time* on my device, which introduces an error to my
> calculation.
>
> Hence, I am wondering, if there is a way to receive this kind of data
> directly and much faster, via "kernel API". My question is related to
> this unanswered one from 2005:
> http://linux.derkeiler.com/Mailing-Lists/RedHat/2005-02/0557.html
>
> *On my device, reading such a file and interpreting the result as
> integer takes 1-10 ms, measured via:
>
>      clock_gettime(CLOCK_MONOTONIC,&t_start);
>      rx_bytes = read_int_from_file("/sys/class/net/wan/statistics/rx_bytes");
>      clock_gettime(CLOCK_MONOTONIC,&t_end);
>
> read_int_from_file() basically consists of fopen(), fgets(), and sscanf().
>
>
> Please note that I don't have kernel/driver programming experience so far.
>
> Thank you for help and any suggestions!
>
>      Jan-Philip Gehrcke

The netlink API can get stats for you, but I don't know if it would
be any more accurate time-wise.  It's not exactly trivial to
implement this API, but you can look at the 'ip' program to get
an idea:

git clone git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git


There is also /proc/net/dev, but that may be worse than using sysfs
as far as performance and time accuracy goes.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

