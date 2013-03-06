From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend
 fails in system sleep
Date: Wed, 6 Mar 2013 10:51:50 +0800
Message-ID: <CACVXFVMMtjfea2N7ZMp1j0q_kcg95_RVx6COQ3hGSaxxwftEaw@mail.gmail.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
	<1362456103-24956-5-git-send-email-ming.lei@canonical.com>
	<87boayqq5c.fsf@nemi.mork.no>
	<CACVXFVMRpf0REYxfi1wtzUpXn2PTCeS6qNfYQP12tW8ca3Sp=g@mail.gmail.com>
	<87d2veot6t.fsf@nemi.mork.no>
	<CACVXFVOg9cVNYsRuAVkexwy4hvD_iJm_vARRksBAeiWppWnoXA@mail.gmail.com>
	<871ubtq47a.fsf@nemi.mork.no>
	<CACVXFVMDNtJOp+8jMOuhCBjrqq-L=jicEJBr_=ErG19Vr+7OGw@mail.gmail.com>
	<87wqtlommw.fsf@nemi.mork.no>
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
In-Reply-To: <87wqtlommw.fsf@nemi.mork.no>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 6, 2013 at 12:08 AM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <ming.lei@canonical.com> writes:
>
> I am starting to wonder why the USB core has combined system suspend =
and
> runtime suspend if we are going to end up with every driver testing
> PMSG_IS_AUTO(message) and selecting a completely different code path.
>
> You are right that we will end up with problems if usbnet_resume is
> called for a device usbnet hasn't suspended.  But I'd still claim tha=
t
> is a bug in the USB core, which is the one that decided to ignore the
> suspend error and still call resume.
>
> I guess proper error handling here require the USB core to see the
> interface driver as dead if it fails to suspend on system suspend, an=
d
> do forced rebinding on resume.

The idea should be fine, but may cause regression of user space, suppos=
e
one device with suspend failure can be across suspend-resume cycle and
work well before, but it is no longer with your forced rebinding.

>
> I am not going to fight this any longer.  The per-driver
> PMSG_IS_AUTO(message) testing is an ugly workround for a core problem=
,
> but they are already all over the place...  Still, please make sure t=
he
> drivers all return 0 if they are pretending to suspend. No error code
> return if the driver ignores the error.

I agree, resume() of driver has to handle the suspend failure if there =
is
the failure returned from suspend().

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
