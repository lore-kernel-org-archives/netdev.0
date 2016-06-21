From: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
Subject: Re: [alsa-devel] [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 21 Jun 2016 10:45:18 -0700
Message-ID: <07283da9-f6d1-c3b1-7989-a6fce7ca0ee6@linux.intel.com>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain> <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk> <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
 <20160618224549.GF32724@icarus.home.austad.us>
 <9a5abd48-4da3-945d-53c9-b6d37010ab0d@linux.intel.com>
 <20160620121838.GA5257@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
	Takashi Sakamoto <o-takashi@sakamocchi.jp>,
	Arnd Bergmann <arnd@linaro.org>, linux-media@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:17707 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606AbcFURtf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 13:49:35 -0400
In-Reply-To: <20160620121838.GA5257@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/20/16 5:18 AM, Richard Cochran wrote:
> On Mon, Jun 20, 2016 at 01:08:27PM +0200, Pierre-Louis Bossart wrote:
>> The ALSA API provides support for 'audio' timestamps (playback/capture rate
>> defined by audio subsystem) and 'system' timestamps (typically linked to
>> TSC/ART) with one option to take synchronized timestamps should the hardware
>> support them.
>
> Thanks for the info.  I just skimmed Documentation/sound/alsa/timestamping.txt.
>
> That is fairly new, only since v4.1.  Are then any apps in the wild
> that I can look at?  AFAICT, OpenAVB, gstreamer, etc, don't use the
> new API.

The ALSA API supports a generic .get_time_info callback, its 
implementation is for now limited to a regular 'DMA' or 'link' timestamp 
for HDaudio - the difference being which counters are used and how close 
they are to the link serializer. The synchronized part is still WIP but 
should come 'soon'

>
>> The intent was that the 'audio' timestamps are translated to a shared time
>> reference managed in userspace by gPTP, which in turn would define if
>> (adaptive) audio sample rate conversion is needed. There is no support at
>> the moment for a 'play_at' function in ALSA, only means to control a
>> feedback loop.
>
> Documentation/sound/alsa/timestamping.txt says:
>
>   If supported in hardware, the absolute link time could also be used
>   to define a precise start time (patches WIP)
>
> Two questions:
>
> 1. Where are the patches?  (If some are coming, I would appreciate
>    being on CC!)
>
> 2. Can you mention specific HW that would support this?

You can experiment with the 'dma' and 'link' timestamps today on any 
HDaudio-based device. Like I said the synchronized part has not been 
upstreamed yet (delays + dependency on ART-to-TSC conversions that made 
it in the kernel recently)
