From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Fri, 23 Jun 2006 13:52:33 +0200
Message-ID: <20060623135233.724a8e51@griffin.suse.cz>
References: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:63885 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S933077AbWFWLwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 07:52:35 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Jun 2006 08:12:24 -0400, Luis R. Rodriguez wrote:
> Kernel level:
> 
> (1) Use the new *configfs* for all user-specific attributes
> (2) Use *sysfs* read-only kobjects for device-specific attributes like
> values which can be saved for suspend() and collected for resume().
> IEEE 802.11 capabilities, features (for example radiotap), and what is
> currently settable/gettable from private ioctl realm along with its
> restrictions can also be exported via sysfs.
> (3) On resume() talk to userspace via netlink to read our sysfs and configfs us

We need a new hostapd<->stack communication protocol. It definitely
cannot be configfs as we need asynchronous events; netlink seems to be
the best solution for this. Why should be a part of 802.11
userspace<->kernel communication done by netlink and part by
configfs/sysfs?

Second, all new network stuff is configured via netlink (or by ioctls,
but that doesn't count). Why should be 802.11 different?

I'd rather choose the way of extending current WE-netlink.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
