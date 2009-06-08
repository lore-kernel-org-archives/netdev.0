From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 7/7] initdev:kernel:Await block device discovery
Date: Mon, 8 Jun 2009 16:13:05 -0700
Message-ID: <20090608231305.GA28992@cuplxvomd02.corp.sa.net>
References: <20090606023416.GA5798@cuplxvomd02.corp.sa.net> <4A2A3F36.4070408@s5r6.in-berlin.de> <20090608223019.GC22222@cuplxvomd02.corp.sa.net> <4A2D96C5.2080604@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A2D96C5.2080604@s5r6.in-berlin.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 09, 2009 at 12:55:01AM +0200, Stefan Richter wrote:
> David VomLehn wrote:
>> On Sat, Jun 06, 2009 at 06:04:38AM -0400, Stefan Richter wrote:
>>> 1.)  It depends on the rootdelay so big that it is guaranteed that 
>>> one or more initdev_found() have been called before 
>>> prepare_namespace()'s ssleep(root_delay) is over.
> ...
>> I think you misunderstood.  Buses are enumerated before this code is
>> reached and thus initdev_found() has already been called for all attached
>> block devices.
> ...
>> I would appreciate it if you could take a closer look at the locations where
>> initdev_found() and initdev_probe_done() are called and see if you still
>> think there is a problem.
>
> I obviously need to do that.
>
> However, one issue remains:  If somebody wants to use your API for  
> another bus, he needs to know at which point he can successfully use it,  
> and after what point (or context) it cannot, even must not, be used  
> anymore.  This isn't documented --- or is it?

Hmm, I tried to make this clear in Documentation/driver-model/initdev.txt,
but I don't claim to be much of a writer and am open to suggestions.

> (By 'buses are enumerated before...' you surely mean only the buses for  
> which you implemented this API usage already.)

Yes, definitely. In an ideal world, every bus which might have a console,
network, or block device would be using this API. USB is a big problem for
me, so that's the itch I scratched. Alan Stern also gave a rub to SCSI.
If people are using devices on, say, Firewire, they will have whatever
behavior they had before the introduction of the API.

> Stefan Richter

David VomLehn
