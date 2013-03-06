From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend
 fails in system sleep
Date: Wed, 6 Mar 2013 15:50:08 +0800
Message-ID: <CACVXFVN+Nwjst2EkPEsnqx0tQ+z922wq7jn7v1Mtmsw+Op86XA@mail.gmail.com>
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
	<CACVXFVN=i10cVS3RQ7jGrJAfsC+r2t61z7XOVKWMAMqKKELZCg@mail.gmail.com>
	<87k3plnh25.fsf@nemi.mork.no>
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
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <87k3plnh25.fsf@nemi.mork.no>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 6, 2013 at 3:06 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <ming.lei@canonical.com> writes:
>> On Wed, Mar 6, 2013 at 10:51 AM, Ming Lei <ming.lei@canonical.com> w=
rote:
>>> On Wed, Mar 6, 2013 at 12:08 AM, Bj=F8rn Mork <bjorn@mork.no> wrote=
:
>>>
>>>> I guess proper error handling here require the USB core to see the
>>>> interface driver as dead if it fails to suspend on system suspend,=
 and
>>>> do forced rebinding on resume.
>>>
>>> The idea should be fine, but may cause regression of user space, su=
ppose
>>> one device with suspend failure can be across suspend-resume cycle =
and
>>> work well before, but it is no longer with your forced rebinding.
>>
>> Give the potential cost(user space regression) of doing rebind, I th=
ink it
>> is better to try to recover the device in resume() first, then
>> consider rebinding
>> as the last straw.  In fact, I am also wondering if resume() can't r=
ecover one
>> device but probe() can, maybe we can always let resume() recover the
>> device which experienced suspend failure.
>
> Yes, sure. Drivers wanting to do this, anticipating typical errors, c=
an
> still return 0 from suspend and do whatever they want in resume.
>
> My proposal is to make the USB core properly deal with drivers return=
ing
> an error from suspend, and also document the fact that a driver shoul=
d
> always return 0 on system suspend unless it really want forced unbind=
ing
> on suspend errors.
>
>> I remember that some guys went against rebinding during system sleep=
 before
>> in the firmware loading discussion.
>
> Yes, that is probably relevant. I'll look it up.  Thanks for the
> pointer.

You are welcome!

Here is one link I found:

       http://marc.info/?l=3Dlinux-usb&m=3D132557022902261&w=3D2

IMO, we unbind interface which hasn't suspend/resume callback
during suspend because there is no better way to handle the case.
But for the suspend failure case, maybe rebind isn't necessary, and
we can document that drivers have to handle their system suspend
failure in resume(), where it is very suitable to do PM recovery.

Also we may store the failure code into usb_interface, and let
USB core check if the suspend failure has been handled/cleared
after resume().

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
