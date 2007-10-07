From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/5] forcedeth: several proposed updates for testing
Date: Sun, 07 Oct 2007 07:34:35 -0400
Message-ID: <4708C44B.40405@garzik.org>
References: <20071006151250.GA17020@havoc.gtf.org> <20071007090808.GB733@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47182 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbXJGLep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 07:34:45 -0400
In-Reply-To: <20071007090808.GB733@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Jeff Garzik <jeff@garzik.org> wrote:
> 
>> * I feel TX NAPI is a useful tool, because it provides an independent TX
>>   process control point and system load feedback point.
>>   Thus I felt this was slightly superior to tasklets.
> 
> /me agrees violently
> 
> btw., when i played with this tunable under -rt:
> 
>  enum {
>          NV_OPTIMIZATION_MODE_THROUGHPUT,
>          NV_OPTIMIZATION_MODE_CPU
>  };
>  static int optimization_mode = NV_OPTIMIZATION_MODE_THROUGHPUT;
> 
> the MODE_CPU one gave (much) _higher_ bandwidth. The queueing model in 
> forcedeth seemed to be not that robust and i think a single queueing 
> model should be adopted instead of this tunable. (which i think just hid 
> some bug/dependency) But i never got to the bottom of it so it's just 
> the impression i got.

That's interesting.  It will be informative to narrow down the variables 
affected by this.  My changes stirred the pot quite a bit :)

* 'throughput' mode enables MSI-X, and separate interrupt vectors for RX 
and TX.  so, NVIDIA's MSI-X implementation, our generic MSI-X support, 
or "Known bugs" (see top of file) may be a factor here.

* 'throughput' mode also changes the NIC's timer interrupt frequency

* do you recall if you were running in NAPI mode?  It defaulted to off 
in Kconfig, but I turned it on unconditionally.

* I think TX NAPI has the potential to make the optimization_mode 
irrelevant (along with the other changes, most notably the interrupt 
handling change)

* and overall, yes, if we can have a single queueing model / 
optimization mode I am strongly in favor of that.

Testing welcome ;-)  Though these patches are raw and "hot off the 
presses", so unrelated bugs are practically a certainty.  And I am 
worrying about the "Known bugs" note at the top.  My gut feeling is that 
this was, in part, misunderstanding on the part of reverse-engineers, 
since corrected when NVIDIA started contributing to the driver.

	Jeff



