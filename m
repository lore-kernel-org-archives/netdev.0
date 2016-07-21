From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC] ethtool bandwidth per-queue commands
Date: Wed, 20 Jul 2016 18:06:19 -0700
Message-ID: <5790200B.8000201@gmail.com>
References: <578FD85F.7080508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kan.liang@intel.com, David Miller <davem@davemloft.net>
To: ivan <khorivan@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34938 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbcGUBGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 21:06:30 -0400
Received: by mail-pf0-f172.google.com with SMTP id x72so24273243pfd.2
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 18:06:30 -0700 (PDT)
In-Reply-To: <578FD85F.7080508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-20 01:00 PM, ivan wrote:
> Hi everyone.
> 
> The ethtool interface has ETHTOOL_PERQUEUE command that is used to
> read/set per-queue parameters for multiqueue Ethernet devices.
> 
> I want to apply additional per-queue commands like per-queue bandwidth
> and per-queue number of descriptors (like number of rings).
> 
> Currently only ETHTOOL_G/SCOALESCE sub commands are added for
> per-queue interface (but I haven't seen counterpart for ethtool util).
> 
> Using ETHTOOL_G/SCOALESCE per-queue command as an example,
> I'm going to add 2 additional and 2 known commands for ethtool
> per-queue interface:
> 
> ETHTOOL_G/SBANDWIDTH     /* Get/Set ethtool per queue bandwidth.
> Bandwidth can be set with % or absolute in Mb/s */
> 

For tx rate limiting we have an ndo op for this already,

   ndo_set_tx_maxrate

which can be tuned via sysfs at the moment. It would logically make
sense to add an rx rate limit if you are looking for something more
like a policer. Or do this via setup_tc() interface as we do with
mqprio qdisc today.

If you are interested in max and min rates per queue groups one such
possibility being a queue group of one you may find the ./net/dcb
stack interesting as well. Although the DCB spec has lots of bits
about protocols and such the kernel interfaces do not care if the
protocol is running at all. Unfortunately when this was done originally
we didn't make this as clear as we should have.

.John
