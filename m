From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 4/4 (v2)] stmmac: fix driver Kconfig when built
 as module
Date: Tue, 05 Jun 2012 07:41:17 +0200
Message-ID: <4FCD9BFD.7090103@st.com>
References: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com> <1338824270-9222-5-git-send-email-peppe.cavallaro@st.com> <CAJ3bTp5ASPyQAqB0CZV1E17uDMpgefQE9pZcPRHbcDMCgeprDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:34107 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752649Ab2FEFlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 01:41:24 -0400
In-Reply-To: <CAJ3bTp5ASPyQAqB0CZV1E17uDMpgefQE9pZcPRHbcDMCgeprDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/5/2012 7:26 AM, Rayagond K wrote:
> Hi Giuseppe,
> 
> On Mon, Jun 4, 2012 at 9:07 PM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com <mailto:peppe.cavallaro@st.com>> wrote:
> 
>     This patches fixes the driver when built as dyn module.
>     In fact the platform part cannot be built and the probe fails
>     (thanks to Bob Liu that reported this bug).
> 
>     v2: as D. Miller suggested, it is not necessary to make the
>     pci and the platform code mutually exclusive.
>     Having both could also help, at built time ,to verify that
>     all the code is validated and compiles fine.
> 

[snip]

>     +static void __exit stmmac_exit(void)
>     +{
>     +       pci_unregister_driver(&stmmac_pci_driver);
>     +       platform_driver_unregister(&stmmac_pltfr_driver);
>     +}
> 
> 
> I guess, unregistering both PCI and platform driver should also be
> conditional else kernel may give warning message *"Unexpected driver
> unregister!".*
> 
> For example PCI driver registration will be successful only if there is
> PCI card on the system/board else registration will be failed, so if the
> register would have failed then unregistering the driver again will
> cause kernel warning message.
> 
> Please see *driver_unregister(*) function which is called from
> *pci_unregister_driver() *for more info.

Hmm, no driver does that because slightly redundant and, IMO, not
necessary in these cases.

Thanks for your feedback.
Peppe
