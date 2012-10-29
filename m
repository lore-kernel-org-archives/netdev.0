From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Information about napi_struct and net_device
Date: Mon, 29 Oct 2012 02:41:01 +0000
Message-ID: <1351478461.4450.8.camel@deadeye.wl.decadent.org.uk>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24659 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757554Ab2J2ClI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 22:41:08 -0400
In-Reply-To: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-27 at 18:18 +0200, Javier Domingo wrote:
> Hello,
> 
> I am updating a kernel patch from 2.6.23-rc7 to v3.6, using git
> facilities, and I have found that there have been lots of changes in
> networking. Now the drivers are all by vendor, and more important,
> net_device is not used always, as napi_struct took its place.
> 
> I have asked in #kernel but no one answered me, so I subscribed here.
> Is there any place I can read about how is it now designed the use of
> napi_struct and net_device? I have found a presentation[1] about how
> networking was changing etc, and I wondered if there is anything more
> precise about how it is actually implemented.
> 
> I understand a little why napi_struct, but don't really know much
> about the change,
> 
> Hope someone can help me,

The initial change to napi_struct is explained in
<http://lwn.net/Articles/244640/>.

Since then there have been further changes:

- netif_napi_del() has been added.  You must call it to clean up NAPI
contexts before freeing the associated net device(s).

- Instead of netif_rx_schedule(), netif_rx_complete(), etc. you must use
napi_schedule(), napi_complete() etc. which just take a napi_struct
pointer.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
