From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Suspending 802.11 drivers
Date: Wed, 21 Jun 2006 11:08:47 -0400
Message-ID: <43e72e890606210808n187771e6k2f58789cf1fcf680@mail.gmail.com>
References: <200606152158.10079.mb@bu3sch.de>
	 <200606162036.26518.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:29170 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751638AbWFUPIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 11:08:49 -0400
Received: by ug-out-1314.google.com with SMTP id a2so2849178ugf
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 08:08:47 -0700 (PDT)
To: "Stefan Rompf" <stefan@loplof.de>
In-Reply-To: <200606162036.26518.stefan@loplof.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/16/06, Stefan Rompf <stefan@loplof.de> wrote:
> Am Donnerstag 15 Juni 2006 21:58 schrieb Michael Buesch:
>
> I think the most important question is how a suspend/resume action should be
> translated. For the managed case, it is clearly an association loss, normally
> signalled by netif_carrier_on/off() and a corresponding SIOCGIWAP event.
> Supplicants can act on this. In AP mode, suspend is equal to disassociating
> all stations. Ad-hoc... dunno.
>
> For a softmac stack like devicescape, it makes sense to have a function that
> abstracts these scenarios as it is the stack anyway that handles association
> stuff. However, I'd rather extend the existing function
> ieee80211_netif_oper().

Since d80211 is already being patched for sysfs how about we use sysfs
(and kobjects) to maintain the state at suspend() and resume(). This
would allow userspace tools like supplicant running in the background
to pick up from sysfs where it left off and for our drivers to save
where we left off. ieee80211_hw can then just refer to their suspend()
and resume() routines from its respective struct pci_driver or struct
usb_device.

  Luis
