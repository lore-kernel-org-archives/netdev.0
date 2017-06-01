From: Adrian Tomasov <atomasov@redhat.com>
Subject: Re: [i40e] regression on TCP stream and TCP maerts,
 kernel-4.12.0-0.rc2
Date: Thu, 01 Jun 2017 12:14:40 +0200
Message-ID: <1496312080.3758.7.camel@redhat.com>
References: <655ed9ab-853e-7497-9ea3-cc8d13f56043@redhat.com>
         <CAKgT0UcdJQWqr_zxxi36a6_3iMwBNow-YS723i7t6xsKvAqvCA@mail.gmail.com>
         <CAKgT0Ufb41o=WM=3DM9cwvrw9N5AFn-uL0p1gQB-m+D3BX3DKA@mail.gmail.com>
         <1496238507.22688.4.camel@redhat.com>
         <CAKgT0Ucg9wHrKDBjQXKH6gziuinwcK9MO-jRC=0q60Lm-8vFqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Adam Okuliar <aokuliar@redhat.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Otto Sabart <osabart@redhat.com>,
        Jirka Hladky <jhladky@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34870 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdFAKOn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 06:14:43 -0400
Received: by mail-wm0-f42.google.com with SMTP id b84so152156852wmh.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 03:14:42 -0700 (PDT)
In-Reply-To: <CAKgT0Ucg9wHrKDBjQXKH6gziuinwcK9MO-jRC=0q60Lm-8vFqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-31 at 14:42 -0700, Alexander Duyck wrote:
> On Wed, May 31, 2017 at 6:48 AM, Adrian Tomasov <atomasov@redhat.com>
> wrote:
> > 
> > On Tue, 2017-05-30 at 18:27 -0700, Alexander Duyck wrote:
> > > 
> > > On Tue, May 30, 2017 at 8:41 AM, Alexander Duyck
> > > <alexander.duyck@gmail.com> wrote:
> > > > 
> > > > 
> > > > On Tue, May 30, 2017 at 6:43 AM, Adam Okuliar <aokuliar@redhat.
> > > > com>
> > > > wrote:
> > > > > 
> > > > > 
> > > > > Hello,
> > > > > 
> > > > > we found regression on intel card(XL710) with i40e driver.
> > > > > Regression is
> > > > > about ~45%
> > > > > on TCP_STREAM and TCP_MAERTS test for IPv4 and IPv6.
> > > > > Regression
> > > > > was first
> > > > > visible in kernel-4.12.0-0.rc1.
> > > > > 
> > > > > More details about results you can see in uploaded images in
> > > > > bugzilla. [0]
> > > > > 
> > > > > 
> > > > > [0] https://bugzilla.kernel.org/show_bug.cgi?id=195923
> > > > > 
> > > > > 
> > > > > Best regards, / S pozdravom,
> > > > > 
> > > > > Adrián Tomašov
> > > > > Kernel Performance QE
> > > > > atomasov@redhat.com
> > > > 
> > > > I have added the i40e driver maintainer and the intel-wired-lan
> > > > mailing list so that we can make are developers aware of the
> > > > issue.
> > > > 
> > > > Thanks.
> > > > 
> > > > - Alex
> > > 
> > > Adam,
> > > 
> > > We are having some issues trying to reproduce what you reported.
> > > 
> > > Can you provide some additional data. Specifically we would be
> > > looking
> > > for an "ethtool -i", and an "ethtool -S" for the port before and
> > > after
> > > the test. If you can attach it to the bugzilla that would be
> > > appreciated.
> > > 
> > > Thanks.
> > > 
> > > - Alex
> > 
> > Hello Alex,
> > 
> > requested files are updated in bugzilla.
> > 
> > If you have any questions about testing feel free to ask.
> > 
> > 
> > Best regards,
> > 
> > Adrian
> 
> So looking at the data I wonder if we don't have an MTU mismatch in
> the network config. I notice the "after" has rx_length_errors being
> reported. Recent changes made it so that i40e doesn't support jumbo
> frames by default, whereas before we could. You might want to check
> for that as that could cause the kind of performance issues you are
> seeing.
> 
> - Alex

There isn't MTU mismatch. Traffic path is : server -> switch ->
server. 


Output from switch:

    > show interfaces et-0/0/18    
    Physical interface: et-0/0/18, Enabled, Physical link is Up
      Interface index: 644, SNMP ifIndex: 538
      Link-level type: Ethernet, MTU: 1514, Speed: 40Gbps, BPDU Error:
    None, MAC-REWRITE Error: None, Loopback: Disabled, Source filtering:
    Disabled, Flow control: Disabled, Media type: Fiber
      Device flags   : Present Running
      Interface flags: SNMP-Traps Internal: 0x4000
      Link flags     : None
      CoS queues     : 12 supported, 12 maximum usable queues
      Current address: d4:04:ff:90:5a:4b, Hardware address:
    d4:04:ff:90:5a:4b
      Last flapped   : 2017-06-01 10:09:32 CEST (01:21:29 ago)
      Input rate     : 432 bps (0 pps)
      Output rate    : 8336 bps (11 pps)
      Active alarms  : None
      Active defects : None
      Interface transmit statistics: Disabled

      Logical interface et-0/0/18.0 (Index 552) (SNMP ifIndex 539)
        Flags: SNMP-Traps 0x24024000 Encapsulation: Ethernet-Bridge
        Input packets : 464041
        Output packets: 209210
        Protocol eth-switch, MTU: 1514
          Flags: Is-Primary, Trunk-Mode


MTU is same for all et-0/0/x interfaces. 

- Adrian
