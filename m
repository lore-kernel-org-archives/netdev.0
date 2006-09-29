From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Fri, 29 Sep 2006 14:10:41 -0700
Message-ID: <451D8BD1.5020906@linux.intel.com>
References: <1159435399.2648.17.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:2899 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750844AbWI2WZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 18:25:33 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159435399.2648.17.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:

>  * Should the userspace daemon be allowed to unilaterally update the
>    regulatory information if it learns something new (via the user)?

Many countries forbid users (root is still a user) being enabled to
override the parameters set up by the hardware vendor as tested for use
with a specific device.

If the hardware and/or driver for the hardware advertises a set of
operating parameters, user space should honor those settings and the
kernel should enforce them.

User space should be able to shrink the set of available spectrum
parameters but should not expand it.

>    Or why not even just publish the regulatory information APs might
>    broadcast in the scan results, and let the userspace daemon pick
>    that apart? Then the kernel need not ask for anything at all...

I think exposing this information to the user would be useful, and
indicate which capabilities are restricted based on information provided
by the kernel and/or hardware driver.  When channel 13 doesn't work, it
should be clear to the user why so they know who to get mad at.

>  * I seem to have read between the lines that the EEPROM data is
>    pretty much useless. Is that generally true, or should the userspace
>    daemon be told what it contains (somehow)?

The EEPROM contents typically represent the configuration and operating
parameters which have been tested and certified to be operational.

These would represent the only settings which a user can operate with
and still be covered by existing certifications.

Regardless of which country you are operating a device in, the device
was intended for sale within a specific geographic and regulatory region
-- it was tested and certified accordingly.  The EEPROM contents
typically provide the information on what was tested and what the
approved operating parameters are for that device.

>  * Should the kernel perform some kind of validation on the regulatory
>    data the daemon gives it as well?

The kernel should enforce the parameters as specified by the
hardware/driver.  In the event that a driver does not advertise a set of
capabilities, the kernel should select the minimal "safe set", which
would be a subset of the 2.4Ghz spectrum and likely exclude all of 5.2Ghz.

> Right now I'd think that it would make sense to just leave the whole
> task to our userspace daemon, iow. nl80211 just provides a command
> to update the kernel's knowledge about regulory and the daemon periodically
> checks the scan results for country information, asks the user for
> the country, or similar. If it's not running, the kernel simply starts
> from a generic no-frills set.

With hardware that restricts operation to the capabilities it was tested
and calibrated for, this will likely result in a broken user experience
-- if they try and use a device on channel 13 and the device restricts
operation to channels 1 - 11, tuning operations will fail.

James
