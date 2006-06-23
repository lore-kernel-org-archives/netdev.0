From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Fri, 23 Jun 2006 10:13:03 -0400
Message-ID: <43e72e890606230713j68f7d167s6e7a90cf148bb3c7@mail.gmail.com>
References: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
	 <20060623135233.724a8e51@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:32524 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750734AbWFWONE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 10:13:04 -0400
Received: by ug-out-1314.google.com with SMTP id a2so1038143ugf
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 07:13:03 -0700 (PDT)
To: "Jiri Benc" <jbenc@suse.cz>
In-Reply-To: <20060623135233.724a8e51@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/23/06, Jiri Benc <jbenc@suse.cz> wrote:
> On Thu, 22 Jun 2006 08:12:24 -0400, Luis R. Rodriguez wrote:
> > Kernel level:
> >
> > (1) Use the new *configfs* for all user-specific attributes
> > (2) Use *sysfs* read-only kobjects for device-specific attributes like
> > values which can be saved for suspend() and collected for resume().
> > IEEE 802.11 capabilities, features (for example radiotap), and what is
> > currently settable/gettable from private ioctl realm along with its
> > restrictions can also be exported via sysfs.
> > (3) On resume() talk to userspace via netlink to read our sysfs and configfs us
>
> We need a new hostapd<->stack communication protocol. It definitely
> cannot be configfs as we need asynchronous events; netlink seems to be
> the best solution for this. Why should be a part of 802.11
> userspace<->kernel communication done by netlink and part by
> configfs/sysfs?

I can see how a hostapd<-->stack communication should be done via
netlink. I wasn't looking for everything to be done via configfs but
just its configuration which parallels perfectly with the design goals
of configfs. I still think it would ease tuning and configuration for
userspace while being nice if used sysfs to export capabilities. A
simple tree on the sysfs tree for the wireless device would list all
the details for the device. Configf's usefulness here may become more
evident if you think in terms of tuning for radiotap -- disalbe/enable
a few bits here and there.

> Second, all new network stuff is configured via netlink (or by ioctls,
> but that doesn't count). Why should be 802.11 different?
>
> I'd rather choose the way of extending current WE-netlink.

Forget about the resume() idea then, what I suggest is just the
configuration of the drivers to be done via configfs while the
driver's capabilities listed via sysfs. I think this would be useful.

  Luis
