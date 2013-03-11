From: CAI Qian <caiqian@redhat.com>
Subject: Re: be2net failed to initialize regression
Date: Sun, 10 Mar 2013 22:07:49 -0400 (EDT)
Message-ID: <1916441684.11871533.1362967669686.JavaMail.root@redhat.com>
References: <CF9D1877D81D214CB0CA0669EFAE020C0F259965@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ivan Vecera <ivecera@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Sathya Perla <Sathya.Perla@Emulex.Com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C0F259965@CMEXMB1.ad.emulex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Sathya Perla" <Sathya.Perla@Emulex.Com>
> To: "CAI Qian" <caiqian@redhat.com>, netdev@vger.kernel.org
> Cc: "Ivan Vecera" <ivecera@redhat.com>, "LKML" <linux-kernel@vger.kernel.org>
> Sent: Friday, March 8, 2013 6:22:24 PM
> Subject: RE: be2net failed to initialize regression
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org
> > [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of CAI Qian
> > 
> > Emulex CNA card failed to initialize using 3.8 and the latest
> > upstream kernel,
> > 
> > [   87.479859] be2net 0000:04:00.0: POST timeout; stage=0xc911
> > [   87.515978] be2net 0000:04:00.0: Emulex OneConnect
> > initialization failed
> > [   87.557130] be2net: probe of 0000:04:00.0 failed with error -1
> > 
> > lspci output,
> > 
> > 04:00.0 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC
> > (rev 02)
> > 04:00.1 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC
> > (rev 02)
> > 
> > 04:00.1 Ethernet controller: Emulex Corporation OneConnect 10Gb NIC
> > (rev 02)
> >         Subsystem: Hewlett-Packard Company NC551i Dual Port
> >         FlexFabric 10Gb
> > Adapter
> > 
> > Confirmed no such problem using 3.7 kernel. Reproduced every time
> > and still
> > bisecting. Just want to give an early head-up to see if anyone saw
> > sometime
> > obvious.
> 
> Could you give me the FW version (ethtool -i) of the adapter (after
> be2net successfully
> probes in a 3.7 kernel.)
firmware-version: 2.104.281.0
> 
> If the FW version is as old as 2.x, then the culprit commit that
> broke compatibility with old FW versions
> on some (BE2) chips I is:
> commit 1bc8e7e4f36c0c19dd7dea29e7c248b7c6ef3a15
> be2net: fix access to SEMAPHORE reg
> 
> The fix for this is (still on David's net tree I guess):
> commit c5b3ad4c67989c778e4753be4f91dc7193a04d21
> be2net: use CSR-BAR SEMAPHORE reg for BE2/BE3
> 
> Dave, can these 2 commits be queued for stable too:
> commit1: c5b3ad4c67989c778e4753be4f91dc7193a04d21
> commit2: 1bc8e7e4f36c0c19dd7dea29e7c248b7c6ef3a15
> 
> thanks,
> -Sathya
> 
