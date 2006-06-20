From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: Intel ixgb driver bug in linux-2.6.17-rc6-mm2
Date: Tue, 20 Jun 2006 14:13:45 -0700
Message-ID: <4807377b0606201413hf77cc1bse70841a52fd08fcb@mail.gmail.com>
References: <20060620193535.GG9200@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, ayyappan.veeraiyan@intel.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.198]:7377 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751096AbWFTVNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 17:13:45 -0400
Received: by nz-out-0102.google.com with SMTP id 9so6372nzo
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 14:13:45 -0700 (PDT)
To: "Linas Vepstas" <linas@austin.ibm.com>
In-Reply-To: <20060620193535.GG9200@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/20/06, Linas Vepstas <linas@austin.ibm.com> wrote:
>
> Hi,
>
> I sat down to do some testing of the ixgb driver a few days ago, and
> get failures within seconds.  From what I can tell, I'm getting either a
> DMA to a bad address or some other PCI bus error, not sure which.
> The problem appears to happen only for the driver that's in
> 2.6.17-rc6-mm2. As a sanity check, I'm testing the SuSE SLES10 beta,
> which is 2.6.16 based, and it doesn't seem to have any problems.
>
> My test is dirt-simple: telnet to the chargen port.  After an eyeblink,
> I get the pci bus error, that's that. "eyeblink" is after about 300MBytes
> transfered.  That was with a driver with NAPI enabled. I tried again
> with NAPI disabled, and got to about 1.8 GB transfered in two eyeblinks.
>
> To make sure that I'm not dealing with faulty hardware, I tried the same
> thing w/ SLES10 2.6.16.18-1.8  and have gotten to RX bytes:20889480686
> (19921.7 Mb) so far, with no problems. I don't have easy access to a PCI
> bus analyzer, otherwise, I'd tell you more. Ideas? Suggestions?
>
> I could try taking the diff between these two driver versions, and
> seeing what change caused the problem, but thought I should email first,
> before doing that.

For some reason I didn't get your mail at intel yet.  anyway, please
try disabling TSO using ethtool and see if that helps any.

you're running 1.0.109, correct?
what does cat /proc/interrupts say (are you running MSI?)

I'd also like to know if LLTX support (recently added) is causing you
the issue.  What hardware platform? pSeries?  does it EEH? what does
the dump say?
