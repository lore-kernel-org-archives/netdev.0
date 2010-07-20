From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces
 with random MAC address
Date: Tue, 20 Jul 2010 14:41:15 +0200
Message-ID: <4C45996B.3000003@redhat.com>
References: <4C457F72.8090708@redhat.com>	 <1279624844.2110.3.camel@achroite.uk.solarflarecom.com>	 <4C458CB7.3030508@redhat.com> <1279627656.2110.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Andy Gospodarek <gospo@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Casey Leedom <leedom@chelsio.com>,
	Harald Hoyer <harald@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279627656.2110.13.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20.07.2010 14:07, Ben Hutchings wrote:
> On Tue, 2010-07-20 at 13:47 +0200, Stefan Assmann wrote:
>> On 20.07.2010 13:20, Ben Hutchings wrote:
>>> On Tue, 2010-07-20 at 12:50 +0200, Stefan Assmann wrote:
>>>> From: Stefan Assmann <sassmann@redhat.com>

[snip]

>> Actually Dave Miller suggested to put it there. What other place is
>> there to put it?
> 
> If Dave said that then I'm sure it's OK.
> 
> However, if you define this as an interface flag (net_device::flags;
> <linux/if.h>) and add it to the set of changeable flags in
> __dev_change_flags(), user-space will be able to clear the flag if it
> later sets a stable address.

As I said I'm not that knowledgeable about this MAC address stealing
thing and I'm assuming that's what you're aiming at. Would you really
want/need it to be user-space writable? Currently all I can think of is
the scenario where you set a "stable" address that outlasts a reboot so
udev might be able to assign it a permanent name after it gets stable.

So it might make sense to have it writable, but I'd like to avoid to add
unnecessary complexity that may cause errors if it's not necessary.
Read-only is simple, just read the flag and deal with it.

Btw, the driver itself could also alter the flag. Then we'd have a well
defined way of setting a stable address.

  Stefan
--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera

> 
> Ben.
> 
