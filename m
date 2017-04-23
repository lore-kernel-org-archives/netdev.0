From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Intel-wired-lan] NFS over NAT causes e1000e transmit hangs
Date: Sun, 23 Apr 2017 10:24:34 -0700
Message-ID: <1492968274.6453.36.camel@edumazet-glaptop3.roam.corp.google.com>
References: <42af0e78-3107-1605-f8e1-d73a8c441ff0@gmail.com>
         <1492542204.10587.138.camel@edumazet-glaptop3.roam.corp.google.com>
         <9fa24846-3a2d-26d3-2963-f5e6ec6808a5@gmail.com>
         <f79d2748-849e-acc6-5e5c-2dc82548fa69@intel.com>
         <50732fb0-d2b6-9395-d982-6eca8c09aedd@gmail.com>
         <81dbcf7d-52f4-4dc0-2355-27198685da7b@intel.com>
         <09a5327d-0cf9-c4ed-5383-2f02c658437e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Neftin, Sasha" <sasha.neftin@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35804 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162177AbdDWRYh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 13:24:37 -0400
Received: by mail-io0-f193.google.com with SMTP id d203so41919009iof.2
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 10:24:37 -0700 (PDT)
In-Reply-To: <09a5327d-0cf9-c4ed-5383-2f02c658437e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-23 at 10:08 -0700, Florian Fainelli wrote:
> 
> On 04/22/2017 11:46 PM, Neftin, Sasha wrote:
> > On 4/20/2017 00:15, Florian Fainelli wrote:
> >> On 04/19/2017 01:52 AM, Neftin, Sasha wrote:
> >>> On 4/18/2017 22:05, Florian Fainelli wrote:
> >>>> On 04/18/2017 12:03 PM, Eric Dumazet wrote:
> >>>>> On Tue, 2017-04-18 at 11:18 -0700, Florian Fainelli wrote:
> >>>>>> Hi,
> >>>>>>
> >>>>>> I am using NFS over a NAT with two e1000e adapters and with eth1
> >>>>>> being
> >>>>>> the LAN interface and eth0 the WAN interface. The kernel is Ubuntu's
> >>>>>> 16.10 kernel: 4.8.0-46-generic. The device doing NAT over NFS is just
> >>>>>> mounting a remote folder and doing normal execution/file accesses.
> >>>>>> It's
> >>>>>> enough to untar a file from this device onto a NFS share to expose
> >>>>>> the
> >>>>>> problem.
> >>>>>>
> >>>>>> The transmit hangs look like the ones below, doing a rmmod/insmod
> >>>>>> does
> >>>>>> not help eliminated the problem, nor does a power cycle. Stopping the
> >>>>>> NFS over NAT definitively does let the adapter recover.
> >>>>> Is this NFS over TCP or UDP ?
> >>>> This is NFS over TCP mounted with the following:
> >>>>
> >>>> type nfs
> >>>> (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=2049,timeo=70,retrans=3,sec=sys,local_lock=none,addr=X.X.X.X)
> >>>>
> >>>>
> >>>>
> >>>> Thanks Eric!
> >>> Please, try disable TCP segmentation offload: ethtool -K <adapter>
> >>> tso off.
> >> I am not able to reproduce the hangs with TSO turned off. Is there a
> >> specific patch you would want me to try?
> > 
> > Please, work with TSO turned off so. There is no patch for this specific
> > problem.
> 
> OK, are not we interested in somehow being able to identify such
> problematic packets coming from the networking stack and force not using
> TSO for those? Would an acceptable solution be to force the disabling of
> TSO for this specific NIC model (provided it is some kind of HW bug)?
> 
> NB: I understand this is very old hardware for you at Intel, but
> conversely, it is very widespread, and chances of people running into
> similar issues are pretty high, so fixing it once would de-facto lower
> the amount of support you'd have to provide in the future.

Indeed it is very odd to disable TSO, especially if the problem only
shows up with NAT.

We probably have a nasty bug somewhere, or we might be able to have a
work around some hardware 'feature'.
