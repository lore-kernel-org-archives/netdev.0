From: Adrian Tomasov <atomasov@redhat.com>
Subject: Re: [Intel-wired-lan] [i40e] regression on TCP stream and TCP
 maerts, kernel-4.12.0-0.rc2
Date: Fri, 09 Jun 2017 12:34:38 +0200
Message-ID: <1497004478.32667.16.camel@redhat.com>
References: <655ed9ab-853e-7497-9ea3-cc8d13f56043@redhat.com>
         <CAKgT0UcdJQWqr_zxxi36a6_3iMwBNow-YS723i7t6xsKvAqvCA@mail.gmail.com>
         <CAKgT0Ufb41o=WM=3DM9cwvrw9N5AFn-uL0p1gQB-m+D3BX3DKA@mail.gmail.com>
         <1496238507.22688.4.camel@redhat.com>
         <CAKgT0Ucg9wHrKDBjQXKH6gziuinwcK9MO-jRC=0q60Lm-8vFqA@mail.gmail.com>
         <1496312080.3758.7.camel@redhat.com> <1496344683.27073.306.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "osabart@redhat.com" <osabart@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "aokuliar@redhat.com" <aokuliar@redhat.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "jhladky@redhat.com" <jhladky@redhat.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36861 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdFIKem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 06:34:42 -0400
Received: by mail-wm0-f50.google.com with SMTP id 7so153819446wmo.1
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 03:34:41 -0700 (PDT)
In-Reply-To: <1496344683.27073.306.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-01 at 19:18 +0000, Duyck, Alexander H wrote:
> On Thu, 2017-06-01 at 12:14 +0200, Adrian Tomasov wrote:
> > 
> > On Wed, 2017-05-31 at 14:42 -0700, Alexander Duyck wrote:
> > > 
> > > 
> > > On Wed, May 31, 2017 at 6:48 AM, Adrian Tomasov <atomasov@redhat.
> > > com>
> > > wrote:
> > > > 
> > > > 
> > > > 
> > > > On Tue, 2017-05-30 at 18:27 -0700, Alexander Duyck wrote:
> > > > > 
> > > > > 
> > > > > 
> > > > > On Tue, May 30, 2017 at 8:41 AM, Alexander Duyck
> > > > > <alexander.duyck@gmail.com> wrote:
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > On Tue, May 30, 2017 at 6:43 AM, Adam Okuliar <aokuliar@red
> > > > > > hat.
> > > > > > com>
> > > > > > wrote:
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > Hello,
> > > > > > > 
> > > > > > > we found regression on intel card(XL710) with i40e
> > > > > > > driver.
> > > > > > > Regression is
> > > > > > > about ~45%
> > > > > > > on TCP_STREAM and TCP_MAERTS test for IPv4 and IPv6.
> > > > > > > Regression
> > > > > > > was first
> > > > > > > visible in kernel-4.12.0-0.rc1.
> > > > > > > 
> > > > > > > More details about results you can see in uploaded images
> > > > > > > in
> > > > > > > bugzilla. [0]
> > > > > > > 
> > > > > > > 
> > > > > > > [0] https://bugzilla.kernel.org/show_bug.cgi?id=195923
> > > > > > > 
> > > > > > > 
> > > > > > > Best regards, / S pozdravom,
> > > > > > > 
> > > > > > > Adrián Tomašov
> > > > > > > Kernel Performance QE
> > > > > > > atomasov@redhat.com
> > > > > > 
> > > > > > I have added the i40e driver maintainer and the intel-
> > > > > > wired-lan
> > > > > > mailing list so that we can make are developers aware of
> > > > > > the
> > > > > > issue.
> > > > > > 
> > > > > > Thanks.
> > > > > > 
> > > > > > - Alex
> > > > > 
> > > > > Adam,
> > > > > 
> > > > > We are having some issues trying to reproduce what you
> > > > > reported.
> > > > > 
> > > > > Can you provide some additional data. Specifically we would
> > > > > be
> > > > > looking
> > > > > for an "ethtool -i", and an "ethtool -S" for the port before
> > > > > and
> > > > > after
> > > > > the test. If you can attach it to the bugzilla that would be
> > > > > appreciated.
> > > > > 
> > > > > Thanks.
> > > > > 
> > > > > - Alex
> > > > 
> > > > Hello Alex,
> > > > 
> > > > requested files are updated in bugzilla.
> > > > 
> > > > If you have any questions about testing feel free to ask.
> > > > 
> > > > 
> > > > Best regards,
> > > > 
> > > > Adrian
> > > 
> > > So looking at the data I wonder if we don't have an MTU mismatch
> > > in
> > > the network config. I notice the "after" has rx_length_errors
> > > being
> > > reported. Recent changes made it so that i40e doesn't support
> > > jumbo
> > > frames by default, whereas before we could. You might want to
> > > check
> > > for that as that could cause the kind of performance issues you
> > > are
> > > seeing.
> > > 
> > > - Alex
> > 
> > There isn't MTU mismatch. Traffic path is : server -> switch ->
> > server. 
> > 
> > 
> > Output from switch:
> > 
> >     > show interfaces et-0/0/18    
> >     Physical interface: et-0/0/18, Enabled, Physical link is Up
> >       Interface index: 644, SNMP ifIndex: 538
> >       Link-level type: Ethernet, MTU: 1514, Speed: 40Gbps, BPDU
> > Error:
> >     None, MAC-REWRITE Error: None, Loopback: Disabled, Source
> > filtering:
> >     Disabled, Flow control: Disabled, Media type: Fiber
> >       Device flags   : Present Running
> >       Interface flags: SNMP-Traps Internal: 0x4000
> >       Link flags     : None
> >       CoS queues     : 12 supported, 12 maximum usable queues
> >       Current address: d4:04:ff:90:5a:4b, Hardware address:
> >     d4:04:ff:90:5a:4b
> >       Last flapped   : 2017-06-01 10:09:32 CEST (01:21:29 ago)
> >       Input rate     : 432 bps (0 pps)
> >       Output rate    : 8336 bps (11 pps)
> >       Active alarms  : None
> >       Active defects : None
> >       Interface transmit statistics: Disabled
> > 
> >       Logical interface et-0/0/18.0 (Index 552) (SNMP ifIndex 539)
> >         Flags: SNMP-Traps 0x24024000 Encapsulation: Ethernet-Bridge
> >         Input packets : 464041
> >         Output packets: 209210
> >         Protocol eth-switch, MTU: 1514
> >           Flags: Is-Primary, Trunk-Mode
> > 
> > 
> > MTU is same for all et-0/0/x interfaces. 
> > 
> > - Adrian
> 
> One thing you might try try doing is toggling the legacy-rx flag
> using
> the "ethtool --show-priv-flags/--set-priv-flags" command to see if
> that
> has any impact. That will help to rule things out as the most
> significant change I can think of is the recent update of the Rx path
> to support XDP.
> 
> Also one other thing you might try would be to use a fixed interrupt
> moderation rate by locking things down using "ethtool -C" to disable
> adaptive interrupt moderation and lock the Rx usecs and Tx usecs at
> some predefined values. I seem to recall there have been some
> interrupt
> moderation changes made recently that might be impacting the
> performance.
> 
> Beyond that is there any chance you would be able to bisect the
> issue?
> Unfortunately we haven't be able to reproduce it internally so
> anything
> that would help us to narrow down the problem would be useful.
> 
> Thanks.
> 
> - Alex

Hello Alex, 

I updated firmware in NIC and it didn't make any changes. Current
firmware version is "firmware-version: 5.05 0x800028a6 1.1568.0".


I tried bisect this issue with new firmware and successfully found
first bad commit. Log from bisecting is pasted in the end. For testing
of kernel builds I used clear distribution install of  RHEL7 and turn
of irqbalance. Test run between 2 servers with same HW an SW
configuration. NIC was put into different IPv4 subnet to avoid
undesirable communication.


testing command : netperf -L 192.168.0.1 -H 192.168.0.2 -T 0,0 -t
TCP_STREAM -l 30 -- -m 4096


[root@vales1 linux]# git bisect good 
47994c119a36e28e1779efabc92d6ab5329a6f75 is the first bad commit
commit 47994c119a36e28e1779efabc92d6ab5329a6f75
Author: Jacob Keller <jacob.e.keller@intel.com>
Date:   Wed Apr 19 09:25:57 2017 -0400

    i40e: remove hw_disabled_flags in favor of using separate flag bits
    
    The hw_disabled_flags field was added as a way of signifying that
    a feature was automatically or temporarily disabled. However, we
    actually only use this for FDir features. Replace its use with new
    _AUTO_DISABLED flags instead. This is more readable, because you
aren't
    setting an *_ENABLED flag to *disable* the feature.
    
    Additionally, clean up a few areas where we used these bits. First,
we
    don't really need to set the auto-disable flag for ATR if we're
fully
    disabling the feature via ethtool.
    
    Second, we should always clear the auto-disable bits in case they
somehow
    got set when the feature was disabled. However, avoid displaying
    a message that we've re-enabled the feature.
    
    Third, we shouldn't be re-enabling ATR in the SB ntuple add flow,
    because it might have been disabled due to space constraints.
Instead,
    we should just wait for the fdir_check_and_reenable to be called by
the
    watchdog.
    
    Overall, this change allows us to simplify some code by removing an
    extra field we didn't need, and the result should make it more
clear as
    to what we're actually doing with these flags.
    
    Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
    Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

:040000 040000 e2f7724e0e857b902ebfeb7104ac18ecf6b90e36
524e5f2381a64fb152ec00638d738a4f28968455 M	drivers
[root@vales1 linux]# git bisect log
git bisect start
# good: [5a7ad1146caa895ad718a534399e38bd2ba721b7] Linux 4.11-rc8
git bisect good 5a7ad1146caa895ad718a534399e38bd2ba721b7
# bad: [2ea659a9ef488125eb46da6eb571de5eae5c43f6] Linux 4.12-rc1
git bisect bad 2ea659a9ef488125eb46da6eb571de5eae5c43f6
# bad: [221656e7c4ce342b99c31eca96c1cbb6d1dce45f] Merge tag 'sound-
4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound
git bisect bad 221656e7c4ce342b99c31eca96c1cbb6d1dce45f
# bad: [8d65b08debc7e62b2c6032d7fe7389d895b92cbc] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect bad 8d65b08debc7e62b2c6032d7fe7389d895b92cbc
# good: [2d2ab658d2debcb4c0e29c9e6f18e5683f3077bf] rhashtable: Do not
lower max_elems when max_size is zero
git bisect good 2d2ab658d2debcb4c0e29c9e6f18e5683f3077bf
# good: [6dc2cce9321198172cd96f955a5fc798a4cc35a6] Merge branch 'x86-
process-for-linus' of
git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 6dc2cce9321198172cd96f955a5fc798a4cc35a6
# good: [b68e7e952f24527de62f4768b1cead91f92f5f6e] Merge branch 'for-
linus' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux
git bisect good b68e7e952f24527de62f4768b1cead91f92f5f6e
# bad: [773225388dae15e72790d6f573e2e70e96292b6b] net: thunderx:
Optimize page recycling for XDP
git bisect bad 773225388dae15e72790d6f573e2e70e96292b6b
# bad: [edd7f4efa8111efc279582290acc4d54d405748a] Merge branch 'bpf-
samples-skb_mode-bug-fixes'
git bisect bad edd7f4efa8111efc279582290acc4d54d405748a
# good: [0da36b9774cc24bac4bff446edf49f31aa98a282] i40e: use
DECLARE_BITMAP for state fields
git bisect good 0da36b9774cc24bac4bff446edf49f31aa98a282
# bad: [1d11e732e7d501c4a231f0b32cf8b81990592689] virtio-net: use
netif_tx_napi_add for tx napi
git bisect bad 1d11e732e7d501c4a231f0b32cf8b81990592689
# bad: [d1f496fd8f34a40458d0eda6be0655926559e546] bpf: restore skb->sk
before pskb_trim() call
git bisect bad d1f496fd8f34a40458d0eda6be0655926559e546
# bad: [3dfc3eb581645bc503c7940861f494a0d75615da] i40evf: hide unused
variable
git bisect bad 3dfc3eb581645bc503c7940861f494a0d75615da
# bad: [47994c119a36e28e1779efabc92d6ab5329a6f75] i40e: remove
hw_disabled_flags in favor of using separate flag bits
git bisect bad 47994c119a36e28e1779efabc92d6ab5329a6f75
# good: [789f38ca70e0b2848472aaf5f278aa3deabd4a4e] i40evf: remove
needless min_t() on num_online_cpus()*2
git bisect good 789f38ca70e0b2848472aaf5f278aa3deabd4a4e
# first bad commit: [47994c119a36e28e1779efabc92d6ab5329a6f75] i40e:
remove hw_disabled_flags in favor of using separate flag bits

[root@vales1 linux]# ethtool -i ens1f0
driver: i40e
version: 2.1.14-k
firmware-version: 5.05 0x800028a6 1.1568.0
expansion-rom-version: 
bus-info: 0000:04:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes


- Adrian
 
