From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Fri, 23 Jun 2006 07:50:47 -0400
Message-ID: <1151063447.2473.6.camel@localhost.localdomain>
References: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58286 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S933071AbWFWLu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 07:50:29 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 08:12 -0400, Luis R. Rodriguez wrote:
> (4) At resume() we could just have our driver read our sysfs
> attributes and try to set all of them back exactly how they were
> before but to reduce bloat on our drivers and since our state is
> already exported we could just have userspace do it for us so... we
> use netlink to communicate to userspace to go ahead and ask it to
> resume() us. Advantages of this would be userspace would always
> consistantly handle the assoc/desassoc and WPA in a consistent manner
> and as mentioned above, driver bloatness killing.

I think having the driver try to set all its state back is pretty much
useless in a large number of cases.  While definitely useful for some
cases, consider:

a) suspend, drive to work, resume
b) WPA-related stuff, which takes much more than simply setting SSID and
encryption key back on the card

Neither of these instances allows the driver to just stick its fingers
in its ears, hum loudly, and pretend nothing happened between suspend
and resume.  Essentially, drivers would be doing all this work for
unencrypted and WEP cases, and then only those cases where the machine
hasn't physically moved.

Our effort is probably better spent elsewhere, especially since many
popular userspace tools already handle resume for us just fine.  More
useful to have drivers just come back from resume in an initialized
state similar to system boot.

Dan


