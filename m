From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Suspending 802.11 drivers
Date: Thu, 22 Jun 2006 06:56:18 -0400
Message-ID: <43e72e890606220356u7b3a5act572697ee4a284a2a@mail.gmail.com>
References: <200606152158.10079.mb@bu3sch.de>
	 <200606162036.26518.stefan@loplof.de>
	 <43e72e890606210808n187771e6k2f58789cf1fcf680@mail.gmail.com>
	 <200606220007.07467.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:51832 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751527AbWFVK4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 06:56:19 -0400
Received: by ug-out-1314.google.com with SMTP id a2so417085ugf
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 03:56:18 -0700 (PDT)
To: "Stefan Rompf" <stefan@loplof.de>
In-Reply-To: <200606220007.07467.stefan@loplof.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/21/06, Stefan Rompf <stefan@loplof.de> wrote:
> Am Mittwoch 21 Juni 2006 17:08 schrieb Luis R. Rodriguez:
>
> > Since d80211 is already being patched for sysfs how about we use sysfs
> > (and kobjects) to maintain the state at suspend() and resume(). This
> > would allow userspace tools like supplicant running in the background
> > to pick up from sysfs where it left off and for our drivers to save
> > where we left off.
>
> Forgive me that I'm so insistant on this question, but this is important: What
> state that goes beyond the data settable with wireless ioctls/iwconfig (that
> is kept anyway) needs to be saved by the stack? Last association info is
> worthless, the assocation can be restored using the ESSID/BSSID/channel set
> with iwconfig or by wpa_supplicant. Important is that userspace is notified
> about the connection loss. Is there _any_ other information not recreatable
> from iwconfig settings that needs to be kept?
>
> Stefan

Stefan, this is an excellent and valid question. Let me elaborate --
Its exactly those settings you mention I'm suggesting get saved onto
sysfs by the driver and later get picked up by userspace. There are,
however, other settings which could get saved when suspending too
though, settings for example, which otherwise would get set by current
private wireless ioctls. There are too many here to describe really,
each device has their own set of of private attributes.

More on this in another e-mail I'm about to send to netdev.

  Luis
