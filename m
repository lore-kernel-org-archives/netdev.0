From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend fails in system sleep
Date: Wed, 06 Mar 2013 09:32:29 +0100
Message-ID: <87fw09nd2a.fsf@nemi.mork.no>
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
	<CACVXFVN+Nwjst2EkPEsnqx0tQ+z922wq7jn7v1Mtmsw+Op86XA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44405 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423Ab3CFIek convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 03:34:40 -0500
In-Reply-To: <CACVXFVN+Nwjst2EkPEsnqx0tQ+z922wq7jn7v1Mtmsw+Op86XA@mail.gmail.com>
	(Ming Lei's message of "Wed, 6 Mar 2013 15:50:08 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:

> Here is one link I found:
>
>        http://marc.info/?l=3Dlinux-usb&m=3D132557022902261&w=3D2

Thanks.  This section caught my eye:

    "The USB suspend/resume code is full of those crazy "let's use one
     function, and pass it as an *argument* what to do". It's a disease=
=2E
     The PM layer used to do the same thing (PMSG_xyz crap), and we've
     largely gotten rid of it, but USB still plays around with those th=
ings
     and makes it even *worse* exactly with these kinds of
     "do_unbind_rebind()" routines that then look at the argument inste=
ad
     of having a sane routine for unbinding and another sane routine fo=
r
     re-binding."


I take that as supporting my view on all the "if (PMSG_IS_AUTO(msg)"
testing...

But I don't have any ideas on how to fix it now that you all have spoon
fed me the background.

> IMO, we unbind interface which hasn't suspend/resume callback
> during suspend because there is no better way to handle the case.
> But for the suspend failure case, maybe rebind isn't necessary, and
> we can document that drivers have to handle their system suspend
> failure in resume(), where it is very suitable to do PM recovery.

Yup, agreed, although I fear that if Alan's commit messages are confuse=
d
then I unable explain anything like this ;)

> Also we may store the failure code into usb_interface, and let
> USB core check if the suspend failure has been handled/cleared
> after resume().

That sounds unnecessarily complicated.  Let the driver deal with
it, keeping the API as simple as possible.


Bj=C3=B8rn
