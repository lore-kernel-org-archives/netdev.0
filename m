From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: WEXT quality specification
Date: Fri, 4 Feb 2005 22:38:54 -0800
Message-ID: <20050205063854.GE9685@jm.kir.nu>
References: <Pine.LNX.4.58.0502042136060.1614@devserv.devel.redhat.com> <20050205052744.GD9685@jm.kir.nu> <Pine.LNX.4.58.0502050043300.7817@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, netdev@oss.sgi.com
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0502050043300.7817@devserv.devel.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 05, 2005 at 01:04:42AM -0500, Dan Williams wrote:

> Reporting received signal strength in RSSI and noise level in dBm won't really 
> work well.  Manufacturers usually provide an RSSI->dBm conversion, but where 
> they don't, the driver needs to be able to provide a MAX_RSSI value.  Otherwise, 
> there is no way for user applications to know the bounds of these values and 
> determine a signal quality % from them.  Again, this is all about consistency, 
> and we need a stable, well-defined API that doesn't depend on user-applications 
> special-casing drivers just to get usable information out of them.  If the 
> driver cannot provide usable information of some sort, it shouldn't even be 
> trying to provide that information at all really.

Agreed, there should be no special cases based on driver in user space.
However, the API definition should not make it too difficult for the
drivers to implement the interface. If many cards use dBm for noise and
RSSI for received frames, it would sound like the API definition should
take this into account and not require the drivers either not to report
values or do some conversion which may not always be that clear.

> qual.qual must be linear (because it should be able to be converted to a 
> percentage value, its a _subjective_ measure of quality composed of a number of 
> different quality statistics).  qual.level & qual.noise may not necessarily be 
> linear since they are measures of electrical power (either RSSI or dBm).

How would this value be determined for cards that have RSSI for received
packets and noise floor in dBm? Using a table of values?

> The current WEXT API provides _no_ way to specify whether the returned values 
> are in dBm or RSSI, other than using max_qual.level == 0 (dBm) and 
> max_qual.level != 0 (RSSI).  That's just the way the API is at this time.  I've 
> brought that up with Jean and he's agreed that it may need some clarification.  
> There isn't really a "qual.type = dBm" bit anywhere in the quality structures, 
> though that would be quite helpful (and was my suggestion).

> See above, technically you could have a noise floor of 0 I guess, and the 
> current WEXT API has no way of specifying different units for use in noise and 
> level at this time.  Hence, the noise value can actually mean something when 
> using dBm as your unit, unlike max_qual.level when using dBm (as it must be 0).

Isn't the 'max_qual.level == 0 means dBm' similar to saying
'max_qual.noise == 0 means dBm' for noise. In other words,
max_qual.level == 70 and max_qual.noise == 0 could mean RSSI for signal
strength and dBm for noise. Using max_qual.noise to report global noise
value (noise floor?) sound somewhat confusing.

> This is really an attempt to clarify the rules as I understand them (and after a 
> couple discussions with Jean about the quality stuff).  I've looked over almost 
> every wireless/802.11 driver that exists for Linux, and none of them 
> implement the standard correctly, probably becuase its a bit ambiguous and 
> nobody could quite understand what they were supposed to do in the quality 
> space.  We need to bring some coherency to drivers in this regard, if only so 
> that people can get their pretty little signal bars in the UI.

Agreed.

-- 
Jouni Malinen                                            PGP id EFC895FA
