From: "Rajashekhara, Sudhakar" <sudhakar.raj@ti.com>
Subject: RE: davinci_emac/mdio: SOFT_RESET of EMAC module resets MDIO on
 AM1808
Date: Tue, 28 Feb 2012 05:46:08 +0000
Message-ID: <B6A220404B6BFC4BBD2AB91C54D39DF431776D23@DBDE01.ent.ti.com>
References: <B6A220404B6BFC4BBD2AB91C54D39DF431775E1B@DBDE01.ent.ti.com>
 <1330092923-10899-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Gole, Anant" <anantgole@ti.com>
To: Christian Riesch <christian.riesch@omicron.at>,
	"Chemparathy, Cyril" <cyril@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:48570 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753347Ab2B1FqU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 00:46:20 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christian,

On Mon, Feb 27, 2012 at 15:44:54, Rajashekhara, Sudhakar wrote:
> Hi Christian,
> 
> On Fri, Feb 24, 2012 at 19:45:23, Christian Riesch wrote:
> > Hello Sudhakar,
> > 
> > On Fri, Feb 24, 2012 at 2:02 PM, Rajashekhara, Sudhakar <sudhakar.raj@ti.com> wrote:
> > > On Thu, Feb 23, 2012 at 14:39:49, Christian Riesch wrote:
> > >> Hi,
> > >> I observed this behavior on a Texas Instruments AM1808 SoC (AM1808
> > >> experimenter's kit) running the current mainline kernel:
> > >>
> 
> [snip]
> 
> > >>
> > >> According to the AM1808 Technical Reference Manual (sections 18.2.14.1
> > >> and 18.3.3.34 in [1]), writing a 1 to the EMAC_SOFTRESET register
> > >> resets the EMAC module, but not the MDIO module. However, when I
> > >> comment out the code above, the MDIO control register is not affected
> > >> and the warning 'resetting idled controller' disappears.
> > >>
> > >
> > > But this was not the case for me. Even after commenting out the above lines,
> > > I could still see that MDIO was getting reset.
> > 
> > Uh, I am sorry. I forgot to mention that there is a second
> > emac_write(EMAC_SOFTRESET,1); in emac_dev_stop() in davinci_emac.c. 
> > This one must also be commented out to make the resetting idled controller 
> > message go away.
> > 
> > The patch below shows that changes that I did. May I please ask you to try
> > again with these changes?
> > 
> 
> I was able to reproduce the issue. I'll debug this further and get back to you.
> 

I was going through the mailing list discussions where a work around for emac
soft-reset tie-up to mdio controller has been proposed. I think this was a known
issue on TI's da8xx family of devices. Please refer to the thread at
http://www.spinics.net/lists/netdev/msg140465.html.

Cyril,
As you have mentioned in your patch, did you get any confirmation from TI designer
regarding emac soft reset behavior? I see that nothing has been mentioned in the
EMAC user guide.

Thanks,
Sudhakar
