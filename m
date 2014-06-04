From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 0/7] net: Support checksum in UDP tunnels
Date: Wed, 4 Jun 2014 16:11:37 -0700
Message-ID: <CA+mtBx8hBvZ6dH1BEZaASQH2bh9=w-TMpF2_NZVRYOAy6cR-Fg@mail.gmail.com>
References: <alpine.DEB.2.02.1406012046040.20298@tomh.mtv.corp.google.com>
	<CAEP_g=9=rCQz6fsZ0c4KP7Kd4L8Q2yk8tKON0GVk52Napj5ufA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:59132 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbaFDXLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 19:11:38 -0400
Received: by mail-ig0-f176.google.com with SMTP id a13so2574216igq.15
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 16:11:38 -0700 (PDT)
In-Reply-To: <CAEP_g=9=rCQz6fsZ0c4KP7Kd4L8Q2yk8tKON0GVk52Napj5ufA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 4, 2014 at 3:28 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Sun, Jun 1, 2014 at 9:00 PM, Tom Herbert <therbert@google.com> wrote:
>> This patch series adds support for using checksums in UDP tunnels. With
>> this it is possible that two or more checksums may be set within the
>> same packet and we would like to do that efficiently.
>
> Do you also plan to implement double checksum offload in the absence
> of TSO? I know it is functionally correct now but it's not offloaded.

We'd need HW support for that (like NETIF_F_HW_CSUM2). I think there
is some justification in light of tunneling protocols over UDP that
carry sensitive data, like virtual network ID, and don't otherwise
have any provision at L3 to detect data corruption (e.g. vxlan).

To implement, I think this is just another pair of checksum offsets
(csum_start, csum_offset) (CHECKSUM_PARTIAL2?) that a driver would
implement. Both csum_start and csum_offset could also be stored in 8
bits (right shifted to give values up to 510) if there are concerns
about space in TX descriptors.

Are any vendors interested in this functionality?

Thanks,
Tom
