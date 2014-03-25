From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3
 buffer overflows triggered by hardware devices
Date: Tue, 25 Mar 2014 10:26:21 -0700
Message-ID: <1395768381.12610.162.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKPWWNFZc8v04-GM5Ttoa-CW_zhNmfMCYO2Q-Yh-75qitSUpiA@mail.gmail.com>
	 <20140324.131733.723749970605014851.davem@davemloft.net>
	 <CAKPWWNF982P7PtuoySy6ncU1mCNFm2RBMEDKr3-QKoCKU-6AMw@mail.gmail.com>
	 <20140324.143512.68893694230434555.davem@davemloft.net>
	 <1395697861.2832.84.camel@deadeye.wl.decadent.org.uk>
	 <CAKPWWNFhqP==HfQC6aV=OFs6Ud6bBDa9hpCrvih8BxDUDo87JA@mail.gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E8463@AcuExch.aculab.com>
	 <CAP6odjh5qgh2dcURHrQ6ERn6a4TfCgBXPm3eJmw2ZsAKyzEzvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	Alon Nafta <alon@privatecore.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Grant Grundler <grantgrundler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:64363 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711AbaCYR0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 13:26:22 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so719052pdj.37
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 10:26:22 -0700 (PDT)
In-Reply-To: <CAP6odjh5qgh2dcURHrQ6ERn6a4TfCgBXPm3eJmw2ZsAKyzEzvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-25 at 09:19 -0700, Grant Grundler wrote:
> On Tue, Mar 25, 2014 at 2:37 AM, David Laight <David.Laight@aculab.com> wrote:
> > From: Alon Nafta
> >> I don't think they should be trusted at all, at least not to a point
> >> where it's feasible for them to execute code on your system.
> >> USB drivers, filesystem drivers, peripheral drivers - they're all on
> >> the same boat, obviously having different levels of severity depending
> >> on driver popularity.
> >
> > On a large number of systems any PCI or PCIe hardware has the
> > ability to read and write any system physical addresses.
> > Not only does this mean that 'dodgy' hardware can change the
> > kernel code, but also any attempt to restrict the memory that
> > the driver itself can access is likely to be circumventable.
> >
> > Yes, you can raise the barrier, but there will always be low
> > points on it.
> 
> David, Alon,
> your points are valid but getting a bit philosophical for me.
> 
> The original patch was trying to address *abuse* of the tulip chip and
> it's not clear to me that's really feasible.  I think this patch is
> "safe" in the sense it enforces correct behavior and AFAICT adds no
> additional CPU cost.

BTW this reminds me :

 http://lkml.iu.edu//hypermail/linux/kernel/1003.3/02073.html

Some hardware have some flaws, not because its malicious but plainly
buggy, and its reasonable to take some basic checks on common 'mistakes'

Checking that the NIC doesn't pretend to receive a bigger frame than the
expected maximum seems reasonable.
