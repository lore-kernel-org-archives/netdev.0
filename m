From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH V3 2/2 RESEND] Introduce huawei_cdc_ncm driver
Date: Thu, 04 Jul 2013 15:19:46 +0200
Message-ID: <87y59mjwct.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
	<87wqp9xja5.fsf@nemi.mork.no>
	<alpine.LNX.2.02.1307021855270.19053@eeeadesso>
	<alpine.LNX.2.02.1307022202570.26010@eeeadesso>
	<alpine.LNX.2.02.1307022207060.26010@eeeadesso>
	<alpine.LNX.2.02.1307022210470.26010@eeeadesso>
	<alpine.LNX.2.02.1307022213380.26010@eeeadesso>
	<alpine.LNX.2.02.1307030836270.12831@eeeadesso>
	<alpine.LNX.2.02.1307030908090.13789@eeeadesso>
	<871u7gvz2z.fsf@nemi.mork.no>
	<alpine.LNX.2.02.1307031455460.24525@eeeadesso>
	<51D424D1.2010507@cogentembedded.com>
	<alpine.LNX.2.02.1307031534180.25440@eeeadesso>
	<1372868333.1919.3.camel@bwh-desktop.uk.level5networks.com>
	<alpine.LNX.2.02.1307032007430.2819@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45942 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828Ab3GDNUM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 09:20:12 -0400
In-Reply-To: <alpine.LNX.2.02.1307032007430.2819@eeeadesso> (Enrico Mioso's
	message of "Wed, 3 Jul 2013 20:11:18 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> This new driver, handles devices that mimic the NCM standard, but usi=
ng NCM as
> a transport layer to encapsulate other protocols (i.e. AT protocol).
>
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
> ---
> V3:
>   - fixed typo in Kconfig (help text)
>
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 287cc62..33cb175 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -246,6 +246,18 @@ config USB_NET_CDC_NCM
>  	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference desig=
n)
>  	    * Ericsson F5521gw Mobile Broadband Module
> =20
> +config USB_NET_HUAWEI_CDC_NCM
> +	tristate "Huawei-style CDC NCM support"
> +	depends on USB_USBNET
> +	select USB_WDM
> +	select USB_NET_CDC_NCM
> +	help
> +		This driver aims to support huawei-style NCM devices, that use ncm=
 as a=20
> +		transport for other protocols.
> +		To compile this driver as a module, choose M here: the module will=
 be=20
> +		called huawei_cdc_ncm.
> +
>  config USB_NET_CDC_MBIM
>  	tristate "CDC MBIM support"
>  	depends on USB_USBNET

Sorry, but editing a patch directly is too risky.  You shouldn't do
that.  This does not apply anymore because there now is a line missing
here...

This is nitpicking, but it needs to be correct for the patches to be
accepted.

Before resubmitting, I suggest:

 - check all the patches with scripts/checkpatch.pl
 - fix absolutely all ERRORs.  You may ignore some WARNINGs if there ar=
e
   good reasons to do so (e.g the 80 character limit)
 - mail all patches to yourself, and save as you receive them
 - apply the received patches to a clean net-next based branch using
   "git am <patch>"
 - verify the result (build it after each patch is applied and play wit=
h
   related config options to make sure nothing breaks)

Also please note that net-next is currently closed due to the merge
window being open: http://www.spinics.net/lists/netdev/msg242161.html

I don't know exactly what the policy wrt new drivers is, but you can
assume that David is pretty busy with the stuff he already has queued.
So it is better to hold this work until after v3.11-rc1 is out and Davi=
d
announces that he has opened net-next again.

And I also believe you should include your final patch to cdc_ncm.c as
part 3/3 of this series.  Otherwise the ordering and dependencies are
not clear.  That patch can be applied on it's own, but it won't make an=
y
sense to do so.  Better make that clear.



Bj=C3=B8rn
