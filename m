From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Sun, 20 Apr 2008 16:42:57 -0600
Message-ID: <fa686aa40804201542x534f891q69790973d9fc0ecd@mail.gmail.com>
References: <200804161640.42693.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: "Laurent Pinchart" <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:5942 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbYDTWm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 18:42:58 -0400
Received: by an-out-0708.google.com with SMTP id d31so421721and.103
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 15:42:57 -0700 (PDT)
In-Reply-To: <200804161640.42693.laurentp@cse-semaphore.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2008 at 8:40 AM, Laurent Pinchart
<laurentp@cse-semaphore.com> wrote:
> This patch converts the MII bitband driver to use GPIO lib for GPIO access.
>  The driver can now handle MDC and MDIO on different GPIO banks.
>
>  The patch depends on Anton Vorontsov GPIO lib support scheduled for 2.6.26.
>  It is by no means complete, I just would like to get some feedback on the
>  approach. I'll resubmit it when the CPM2 GPIO support patches will be
>  available in the powerpc git tree.

I agree with Anton; nice rework.  This would be useful on other
platforms too.  Comment below.

>  --- a/Documentation/powerpc/booting-without-of.txt
>  +++ b/Documentation/powerpc/booting-without-of.txt
>  @@ -2030,21 +2030,19 @@ platforms are moved over to use the flattened-device-tree model.
>     fsl,cpm2-mdio-bitbang (reg is port C registers)
>
>     Properties for fsl,cpm2-mdio-bitbang:
>  -   fsl,mdio-pin : pin of port C controlling mdio data
>  -   fsl,mdc-pin : pin of port C controlling mdio clock
>  +   gpios : GPIOs controlling mdio clock and mdio data (in that order).
>
>     Example:
>
>  -       mdio@10d40 {
>  +       mdio {
>                 device_type = "mdio";
>                 compatible = "fsl,mpc8272ads-mdio-bitbang",
>                              "fsl,mpc8272-mdio-bitbang",
>                              "fsl,cpm2-mdio-bitbang";

I think it would be better for the defined binding to use something
like "virtual,mdio-bitbang" or "gpio-mdio".  (I like the first better,
but there is already some precedence with the "gpio-led" driver.  I
think there is less chance of namespace conflicts with the first)

Of course; the *driver* could also accept these additional compatible
values for backwards compatibility.

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
