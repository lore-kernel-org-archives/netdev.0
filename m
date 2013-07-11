From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: A performance regression of gretap
Date: Thu, 11 Jul 2013 00:47:00 -0700
Message-ID: <CALnjE+oL9s9QxJkGwKW4Xmq7U+i-ndAir3+XitY-i2-mPfk1xg@mail.gmail.com>
References: <327738182.1491147.1373450503005.JavaMail.root@redhat.com>
	<1373508910.12250.4.camel@cr0>
	<CALnjE+oNMcXORdMgzHtomdf+EDknZaCsiB-+aevMbg-rsxbpww@mail.gmail.com>
	<1373509919.12250.6.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:54742 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752330Ab3GKHrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 03:47:02 -0400
Received: by mail-qe0-f50.google.com with SMTP id f6so4185430qej.23
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 00:47:01 -0700 (PDT)
In-Reply-To: <1373509919.12250.6.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 7:31 PM, Cong Wang <amwang@redhat.com> wrote:
> On Wed, 2013-07-10 at 19:28 -0700, Pravin Shelar wrote:
>> On Wed, Jul 10, 2013 at 7:15 PM, Cong Wang <amwang@redhat.com> wrote:
>> > On Wed, 2013-07-10 at 06:01 -0400, Cong Wang wrote:
>> >>
>> >> Could you please take a look? And, gre tunnel is fine, this
>> >> problem only exists for gretap. I reviewed the gretap code,
>> >> but can't find any bug.
>> >
>> > After digging it a little bit, I found some of the packets on RX side
>> > have incorrect TCP checksum after going through gretap, while the
>> > packets captured on eth0 are all correct.
>> >
>> > Thanks.
>> >
>> I do not see it on my end.
>> Can you tell me NIC type and features set for eth device?
>
> Sure, it is virtio_net which is not able to do rx checksum, therefore
> ->ip_summed is CHECKSUM_NONE.
>
> # ethtool -i eth0
> driver: virtio_net
> version: 1.0.0
> firmware-version:
> bus-info: 0000:00:08.0
> supports-statistics: no
> supports-test: no
> supports-eeprom-access: no
> supports-register-dump: no
> supports-priv-flags: no
>
> # ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: off
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: on
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: off
> tx-vlan-offload: off
> ntuple-filters: off
> receive-hashing: off
>
>

I could not reproduce the issue on NIC with similar feat, I will try
virtio tomorrow.
