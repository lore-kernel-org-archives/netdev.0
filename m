From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: Intel ixgb driver bug in linux-2.6.17-rc6-mm2
Date: Wed, 21 Jun 2006 15:18:50 -0500
Message-ID: <20060621201850.GH8866@austin.ibm.com>
References: <20060620193535.GG9200@austin.ibm.com> <4807377b0606201413hf77cc1bse70841a52fd08fcb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, ayyappan.veeraiyan@intel.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org, wenxiong@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:17301 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751377AbWFUUSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2006 16:18:53 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5LKIpD1005987
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 16:18:52 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5LKIpCp260478
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 16:18:51 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5LKIp3C014560
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 16:18:51 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Disposition: inline
In-Reply-To: <4807377b0606201413hf77cc1bse70841a52fd08fcb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 02:13:45PM -0700, Jesse Brandeburg wrote:
> On 6/20/06, Linas Vepstas <linas@austin.ibm.com> wrote:
> >
> >I sat down to do some testing of the ixgb driver a few days ago, and
> >get failures within seconds.  From what I can tell, I'm getting either a
> >DMA to a bad address or some other PCI bus error, not sure which.
> >The problem appears to happen only for the driver that's in
> >2.6.17-rc6-mm2. As a sanity check, I'm testing the SuSE SLES10 beta,
> >which is 2.6.16 based, and it doesn't seem to have any problems.
> >
> >My test is dirt-simple: telnet to the chargen port.  After an eyeblink,
> >I get the pci bus error, that's that. "eyeblink" is after about 300MBytes
> >transfered.  That was with a driver with NAPI enabled. I tried again
> >with NAPI disabled, and got to about 1.8 GB transfered in two eyeblinks.
> >
> >To make sure that I'm not dealing with faulty hardware, I tried the same
> >thing w/ SLES10 2.6.16.18-1.8  and have gotten to RX bytes:20889480686
> >(19921.7 Mb) so far, with no problems. I don't have easy access to a PCI
> >bus analyzer, otherwise, I'd tell you more. Ideas? Suggestions?
> >
> >I could try taking the diff between these two driver versions, and
> >seeing what change caused the problem, but thought I should email first,
> >before doing that.

> try disabling TSO using ethtool and see if that helps any.

Bing!  That appears to have fixed it !

> you're running 1.0.109, correct?

Yes.  DRV_VERSION     "1.0.109-k2"

> what does cat /proc/interrupts say (are you running MSI?)

No MSI, this is on older hardware.  
163:       3769     450130      14983     439113   XICS      Edge nic5

> I'd also like to know if LLTX support (recently added) is causing you
> the issue.  What hardware platform? pSeries?  does it EEH? what does
> the dump say?

Yes, its pseries; yes, I see this as EEH errors. However, the EEH error
detection is asynchronous, and so the Linux tack trace is throughly
boring: the error is first noticed when the watchdog runs, typically.

--linas

p.s. version 1.0.100-k2 works gret with NAPI on, and the defal TSO.
I haven't yet tried 1.0.109 with NAPI on and TSO off.

--linas
