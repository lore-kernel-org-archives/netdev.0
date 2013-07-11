From: Cong Wang <amwang@redhat.com>
Subject: Re: A performance regression of gretap
Date: Thu, 11 Jul 2013 10:31:59 +0800
Message-ID: <1373509919.12250.6.camel@cr0>
References: <327738182.1491147.1373450503005.JavaMail.root@redhat.com>
	 <1373508910.12250.4.camel@cr0>
	 <CALnjE+oNMcXORdMgzHtomdf+EDknZaCsiB-+aevMbg-rsxbpww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755063Ab3GKCcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 22:32:10 -0400
In-Reply-To: <CALnjE+oNMcXORdMgzHtomdf+EDknZaCsiB-+aevMbg-rsxbpww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-10 at 19:28 -0700, Pravin Shelar wrote:
> On Wed, Jul 10, 2013 at 7:15 PM, Cong Wang <amwang@redhat.com> wrote:
> > On Wed, 2013-07-10 at 06:01 -0400, Cong Wang wrote:
> >>
> >> Could you please take a look? And, gre tunnel is fine, this
> >> problem only exists for gretap. I reviewed the gretap code,
> >> but can't find any bug.
> >
> > After digging it a little bit, I found some of the packets on RX side
> > have incorrect TCP checksum after going through gretap, while the
> > packets captured on eth0 are all correct.
> >
> > Thanks.
> >
> I do not see it on my end.
> Can you tell me NIC type and features set for eth device?

Sure, it is virtio_net which is not able to do rx checksum, therefore
->ip_summed is CHECKSUM_NONE.

# ethtool -i eth0
driver: virtio_net
version: 1.0.0
firmware-version: 
bus-info: 0000:00:08.0
supports-statistics: no
supports-test: no
supports-eeprom-access: no
supports-register-dump: no
supports-priv-flags: no

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: off
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: off
tx-vlan-offload: off
ntuple-filters: off
receive-hashing: off
