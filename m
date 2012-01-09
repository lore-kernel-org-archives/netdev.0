From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: Re: [PATCH RFC] iwlwifi: add basic runtime PM support
Date: Mon, 09 Jan 2012 09:01:22 +0800
Message-ID: <4F0A3C62.6010403@intel.com>
References: <4F065F59.2070107@intel.com> <1325843269.3330.4.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy@intel.com, ilw@linux.intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51722 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755050Ab2AIBBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jan 2012 20:01:24 -0500
In-Reply-To: <1325843269.3330.4.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2012 05:47 PM, Johannes Berg wrote:
> [add linux-wireless]
> 
> On Fri, 2012-01-06 at 10:41 +0800, Yan, Zheng wrote:
>> This simple patch adds open/close based runtime PM support to the iwlwifi driver.
>> Namely, make the driver suspend the device after shutting down the interface and
>> resume the device when activating the interface. In my test, suspending the device
>> can save about 0.4 watt power. The shortcoming is that the device no longer generate
>> rfkill changes interrupt.
> 
> NACK due to that last sentence. There's no way we can live with that in
> the general case -- and your patch isn't even configurable afaict. And
> I'm sure polling the rfkill flag would use just as much energy.
> 
It's configurable, runtime PM is disabled by default.

> There might be some value in this in a system that doesn't have a hard
> rfkill line, but that means this needs to be configurable since the
> device can't know whether there's a button or not [1].
> 
The patch targets system that only use software rfkill

Regards
Yan, Zheng


> johannes
> 
> [1] actually in theory it might be possible to determine whether or not
> the pin is floating or not? I doubt even that is possible with the HW we
> have though
> 
