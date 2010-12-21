From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: IPTV buffering
Date: Tue, 21 Dec 2010 17:24:23 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1012211634330.21593@ask.diku.dk>
References: <20101216111843.88E16F0C32AB5@borg.medozas.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-104410420-1292948663=:21593"
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:54718 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158Ab0LUQY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 11:24:29 -0500
In-Reply-To: <20101216111843.88E16F0C32AB5@borg.medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-104410420-1292948663=:21593
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT


On Thu, 16 Dec 2010, Jan Engelhardt wrote:
> On Thursday 2010-12-16 10:57, Jesper Dangaard Brouer wrote:
>
>> [...] NetConf 2010, see:
>>
>> http://vger.kernel.org/netconf2010.html
>
> I just went over a few slide sets, and noticed Dave's Netfilter summary
> about your IPTV talk, enlisting the point
>
> * Ethernet switches buffer too small
>
> ("too small".. "too few"?) Given the recent uproar about bufferbloat in
> routing devices (see LWN coverage about Getty's articles), wanting
> larger buffers seems to almost contradict what Getty would like.

Always wanting small buffers doesn't make sense.  It seem that he is not 
considering that network equipment can be used for other things than 
TCP/IP.

What I want is a *smooth* IPTV multicast signal (which thus consumes 
minimal buffer space), but because the streamers are bursting packets, I 
want large enough buffers in the switch, to handle these bursts.

What I recommend (in the backbone) is to increase the buffer size in the 
QoS queue, which is used for e.g. IPTV/multicast.  And have another queue 
for the normal Internet traffic (because too large buffers can cause 
issues).


> Though TV is usually delivered via UDP rather than TCP, some of the
> protocols may too implement some sort of congestion recognition or
> even avoidance technique ÿÿ IIRC realplayer had something that
> adapted video quality based upon transfer rate.

Our TV streamer send out a MULTICAST signal, thus there is NOT any
congestion feedback...


> Wanting more buffers vs. wanting less buffering seems to be quite
> contradictory. Jesper, what is your take on this?

Skimming through Getty's blog post, I think Getty has actually missed what 
is happening.  He should read my masters thesis[1]... The real problem is 
that TCP/IP is clocked by the ACK packets, and on asymetric links (like 
ADSL and DOCSIS), the ACK packets are simply comming downstream too fast 
on the larger downstream link, resulting in bursts and high-latency on the 
upstream link.

With the ADSL-optimizer I actually solved Gettys problem, but I guess the 
real solution would be to implement a TCP algorithm which handels this 
asymmtry, and e.g. isn't based on the ACK feedback...

[1] http://www.adsl-optimizer.dk/thesis/

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-104410420-1292948663=:21593--
