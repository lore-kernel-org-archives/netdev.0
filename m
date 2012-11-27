From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] [INET]: Get cirtical word in first 64bit of cache
 line
Date: Tue, 27 Nov 2012 05:58:03 -0800
Message-ID: <1354024683.7553.1768.camel@edumazet-glaptop>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
	 <1353912241.30446.1257.camel@edumazet-glaptop>
	 <CAOGi=dPQWC8hgt4jhMEHcVPb6j+jMTguNAchiLjdvvHjarCW4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Ling Ma <ling.ma.program@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOGi=dPQWC8hgt4jhMEHcVPb6j+jMTguNAchiLjdvvHjarCW4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-11-27 at 21:48 +0800, Ling Ma wrote:

> Ling: in the looking-up routine, hash value is the most important key,
> if it is matched,  the other values have most possibility to be
> satisfied, and CFW is limited by memory bandwidth(64bit usually), so
> we only move hash value as critical first word.

In practice, we have at most one TCP socket per hash slot.
99.9999 % of lookups need all fields to complete.

Your patch introduces a misalignment error. I am not sure all 64 bit
arches are able to cope with that gracefully.

It seems all CWF docs I could find are very old stuff, mostly academic,
without good performance data.

I was asking for up2date statements from Intel/AMD/... about current
cpus and current memory. Because optimizing for 10 years olds cpus is
not worth the pain.

I am assuming cpus are implementing the CWF/ER automatically, and that
only prefetches could have a slight disadvantage if the needed word is
not the first word in the cache line. Its not clear why the prefetch()
hint could not also use CWF. It seems it also could be done by the
hardware.

So before random patches in linux kernel adding their possible bugs, we
need a good study.

Thanks
