From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 0/9] Introduce devlink interface and first
 drivers to use it
Date: Thu, 25 Feb 2016 22:12:56 +0100
Message-ID: <20160225211256.GA2164@nanopsycho.orion>
References: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
 <20160225.151247.479900417232368503.davem@davemloft.net>
 <56CF67BB.70901@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, yishaih@mellanox.com, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	eugenia@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	brouer@redhat.com, ivecera@redhat.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34697 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbcBYVM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:12:59 -0500
Received: by mail-wm0-f50.google.com with SMTP id b205so48506507wmb.1
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 13:12:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56CF67BB.70901@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 25, 2016 at 09:44:43PM CET, hannes@stressinduktion.org wrote:
>On 25.02.2016 21:12, David Miller wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Tue, 23 Feb 2016 16:51:25 +0100
>>
>>>There a is need for some userspace API that would allow to expose things
>>>that are not directly related to any device class like net_device of
>>>ib_device, but rather chip-wide/switch-ASIC-wide stuff.
>>>
>>>Use cases:
>>>1) get/set of port type (Ethernet/InfiniBand)
>>>2) setting up port splitters - split port into multiple ones and squash again,
>>>    enables usage of splitter cable
>>>3) setting up shared buffers - shared among multiple ports within
>>>    one chip (work in progress)
>>>4) configuration of switch wide properties - resources division etc - This will
>>>    allow to pass configuration that is unacceptable to be passed as
>>>    a module option.
>>>
>>>First patch of this set introduces a new generic Netlink based interface,
>>>called "devlink". It is similar to nl80211 model and it is heavily
>>>influenced by it, including the API definition. The devlink introduction patch
>>>implements use cases 1) and 2). Other 2 are in development atm and will
>>>be addressed by follow-ups.
>>>
>>>It is very convenient for drivers to use devlink, as you can see in other
>>>patches in this set.
>>>
>>>Counterpart for devlink is userspace tool for now called "dl". Command line
>>>interface and outputs are derived from "ip" tool so it should be easy
>>>for users to get used to it.
>>
>>I am very close to applying this series as-is.
>>
>>The clincher for me is that there is precendence in the nl80211 stuff,
>>so obviously whatever userland infrastructure sits on top of that has
>>found a way to deal whatever perceived shortcomings devlink has.
>
>Actually nl80211 phy interfaces aren't really managed by wpa_supplicant nor
>NetworkManager, but they use net_device names to discover those later on. In
>devlink we don't necessarily have netdev names, thus my only objection to
>this series is to switch to stable topology identifiers.

Hannes, as I mentioned earlier in one of my replies, you can choose to
use devlink name or pci (or other) address for your commands. So you
have your stable names even before udev takes care of renaming. It's up
to you as a user what handle to use.
