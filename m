From: Nigel Cunningham <ncunningham@linuxmail.org>
Subject: Re: 2.4.29, e100 and a WOL packet causes keventd going mad
Date: Mon, 31 Jan 2005 20:08:03 +1100
Message-ID: <1107162475.4234.26.camel@desktop.cunninghams>
References: <20050130171849.GA3354@hardeman.nu>
	 <1107143255.18167.428.camel@localhost.localdomain>
	 <1107143905.21273.33.camel@desktop.cunninghams>
	 <1107147615.18167.433.camel@localhost.localdomain>
	 <1107152056.21273.56.camel@desktop.cunninghams>
Reply-To: ncunningham@linuxmail.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David =?ISO-8859-1?Q?H=E4rdeman?= <david@2gen.com>,
	Michael Gernoth <simigern@stud.uni-erlangen.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261635AbVAaJGE@vger.kernel.org>
To: sfeldma@pobox.com
In-Reply-To: <1107152056.21273.56.camel@desktop.cunninghams>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again.

Ignore that :> I realised later that there's only one badly named
routine and my assumption that there was another called disable_.. was
wrong :>

Nigel

On Mon, 2005-01-31 at 17:14, Nigel Cunningham wrote:
> Hi.
> 
> On Mon, 2005-01-31 at 16:00, Scott Feldman wrote:
> > On Sun, 2005-01-30 at 19:58, Nigel Cunningham wrote:
> > > Do you also disable the WOL event when resuming?
> > 
> > Good catch.  How's this look?
> 
> I looked at it last week because I used it for an example of device
> model drivers at the CELF conference. I got your intel address from the
> top of the .c file, but IIRC it bounced. Providence :>
> 
> [...]
> 
> > @@ -2333,6 +2331,7 @@ static int e100_resume(struct pci_dev *p
> >  	struct nic *nic = netdev_priv(netdev);
> >  
> >  	pci_set_power_state(pdev, PCI_D0);
> > +	pci_enable_wake(pdev, PCI_D0, 0);
> >  	pci_restore_state(pdev);
> >  	e100_hw_init(nic);
> 
> Shouldn't this be disable_wake?
> 
> Regards,
> 
> Nigel
-- 
Nigel Cunningham
Software Engineer, Canberra, Australia
http://www.cyclades.com

Ph: +61 (2) 6292 8028      Mob: +61 (417) 100 574
