From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend
 fails in system sleep
Date: Wed, 6 Mar 2013 11:03:40 +0800
Message-ID: <CACVXFVN=i10cVS3RQ7jGrJAfsC+r2t61z7XOVKWMAMqKKELZCg@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-5-git-send-email-ming.lei@canonical.com>
	<87boayqq5c.fsf@nemi.mork.no>
	<CACVXFVMRpf0REYxfi1wtzUpXn2PTCeS6qNfYQP12tW8ca3Sp=g@mail.gmail.com>
	<87d2veot6t.fsf@nemi.mork.no>
	<CACVXFVOg9cVNYsRuAVkexwy4hvD_iJm_vARRksBAeiWppWnoXA@mail.gmail.com>
	<871ubtq47a.fsf@nemi.mork.no>
	<CACVXFVMDNtJOp+8jMOuhCBjrqq-L=jicEJBr_=ErG19Vr+7OGw@mail.gmail.com>
	<87wqtlommw.fsf@nemi.mork.no>
	<CACVXFVMMtjfea2N7ZMp1j0q_kcg95_RVx6COQ3hGSaxxwftEaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:39121 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762Ab3CFDDn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 22:03:43 -0500
In-Reply-To: <CACVXFVMMtjfea2N7ZMp1j0q_kcg95_RVx6COQ3hGSaxxwftEaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 6, 2013 at 10:51 AM, Ming Lei <ming.lei@canonical.com> wrot=
e:
> On Wed, Mar 6, 2013 at 12:08 AM, Bj=F8rn Mork <bjorn@mork.no> wrote:
>> Ming Lei <ming.lei@canonical.com> writes:
>>
>> I am starting to wonder why the USB core has combined system suspend=
 and
>> runtime suspend if we are going to end up with every driver testing
>> PMSG_IS_AUTO(message) and selecting a completely different code path=
=2E
>>
>> You are right that we will end up with problems if usbnet_resume is
>> called for a device usbnet hasn't suspended.  But I'd still claim th=
at
>> is a bug in the USB core, which is the one that decided to ignore th=
e
>> suspend error and still call resume.
>>
>> I guess proper error handling here require the USB core to see the
>> interface driver as dead if it fails to suspend on system suspend, a=
nd
>> do forced rebinding on resume.
>
> The idea should be fine, but may cause regression of user space, supp=
ose
> one device with suspend failure can be across suspend-resume cycle an=
d
> work well before, but it is no longer with your forced rebinding.

Give the potential cost(user space regression) of doing rebind, I think=
 it
is better to try to recover the device in resume() first, then
consider rebinding
as the last straw.  In fact, I am also wondering if resume() can't reco=
ver one
device but probe() can, maybe we can always let resume() recover the
device which experienced suspend failure.

I remember that some guys went against rebinding during system sleep be=
fore
in the firmware loading discussion.

Thanks,
--
Ming Lei
