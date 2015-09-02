From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 05/19] ixgbe: Add support for UDP-encapsulated tx
 checksum offload
Date: Thu, 3 Sep 2015 00:07:17 +0300
Message-ID: <CAJ3xEMhLyP-S3EMC9L-utr-YMZmbZiE54cxMZT0pTGwHhqweew@mail.gmail.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1441156443-33381-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<CALx6S34-mUvQyUQNcVC+o+NeUxWEsCG2GS=Eq++eGqoh=kv8kg@mail.gmail.com>
	<F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
	<CALx6S36T4tzB5aq3bbKq4DMEumvC4q2YhGscn19se0mGXGe5cQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34729 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbbIBVHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 17:07:18 -0400
Received: by oiev17 with SMTP id v17so13740222oie.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 14:07:17 -0700 (PDT)
In-Reply-To: <CALx6S36T4tzB5aq3bbKq4DMEumvC4q2YhGscn19se0mGXGe5cQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 2, 2015 at 8:38 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Wed, Sep 2, 2015 at 9:46 AM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:

>> Note: NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM + NETIF_F_IPV6_CSUM.
>> It means that device can fill TCP/UDP-like checksum anywhere in the packets
>> whatever headers there might be.

>> The device can't do whatever, wherever. There is always a limit to the offset to the inner headers that can be handled, for instance.

> If the device does NETIF_F_HW_CSUM then inner/outer headers are
> irrelevant at least in the non-GSO case. All the device needs to do is
> compute the checksum from start and write the answer at the given
> offset. No protocol awareness needed in the device, no need to parse
> headers on transmit.

Tom, could you elaborate a little further on the
semantics/requirements for devices supporting NETIF_F_HW_CSUM,
specifically, AFAIU this isn't a TX equivalent of supporting checksum
complete on RX, right? when you say "write the answer at the given
offset" what non-common answers are you expecting devices to produce?
how the kernel is hinting to the device on the nature on the expected
answer beyond the offset?

Or.
