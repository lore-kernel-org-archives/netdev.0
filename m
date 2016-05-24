From: Brandon Philips <brandon@ifup.co>
Subject: Re: ixgbe: ksoftirqd consumes 100% CPU w/ ~50 TCP conns
Date: Tue, 24 May 2016 09:40:14 -0700
Message-ID: <CAEm7KtxaUC0uBM9sAQSqBeT7AhyEBK=950AxT7N4imgcQ1TnwQ@mail.gmail.com>
References: <CAEm7KtxXapo-9OevQtFAnuZo5h4FH8RQ-Nm3in4A0uJh0KqYKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Matthew Garrett <mjg59@srcf.ucam.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Mark Rustad <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f72.google.com ([209.85.213.72]:36148 "EHLO
	mail-vk0-f72.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932553AbcEXRG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 13:06:28 -0400
Received: by mail-vk0-f72.google.com with SMTP id c67so51202416vkh.3
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 10:06:27 -0700 (PDT)
In-Reply-To: <CAEm7KtxXapo-9OevQtFAnuZo5h4FH8RQ-Nm3in4A0uJh0KqYKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Everyone-

So we tracked it down to IOMMU causing CPU affinity getting broken[1].
Can we provide any further details or is this a known issue?

Thank You,

Brandon

[1] https://github.com/coreos/bugs/issues/1275#issuecomment-219866601

On Tue, May 17, 2016 at 12:44 PM, Brandon Philips <brandon@ifup.co> wrote:
> Hello ixgbe team-
>
> With Linux v4.6 and the ixgbe driver (details below) a user is reporting
> ksoftirqd consuming 100% of the CPU on all cores after a moderate  ~20-50
> number of TCP connections. They are unable to reproduce this issue with
> Cisco hardware.
>
> With Kernel v3.19 they cannot reproduce[1] the issue. Disabling IOMMU
> (intel_iommu=off) does "fix" the issue[2].
>
> Thank You,
>
> Brandon
>
> [1] https://github.com/coreos/bugs/issues/1275#issuecomment-219157803
> [2] https://github.com/coreos/bugs/issues/1275#issuecomment-219819986
>
> Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection (rev 01)
> ethtool -i eno1
> driver: ixgbe
> version: 4.0.1-k
> firmware-version: 0x800004e0
> bus-info: 0000:06:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> supports-priv-flags: no
>
> CPU
> Intel(R) Xeon(R) CPU E5-2690 v3 @ 2.60GHz
