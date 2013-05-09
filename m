From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC iproute2] Add VF link state control
Date: Thu, 9 May 2013 11:34:47 +0300
Message-ID: <CAJZOPZ+bHAOH-TMGaosZHZ8ibKQRGN1BLkJbM1r203UmSytSig@mail.gmail.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	<1368020717-22194-4-git-send-email-ogerlitz@mellanox.com>
	<20130508091753.0be79e6c@nehalam.linuxnetplumber.net>
	<1368030286.1664.16.camel@dcbw.foobar.com>
	<518A80F6.5060605@intel.com>
	<CAJZOPZKGGj=531UVDw-47mWD7LGQ7AYh1c7cZwv_08p0Lz1Gtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Rony Efraim <ronye@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:41095 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab3EIIes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 04:34:48 -0400
Received: by mail-qc0-f173.google.com with SMTP id c11so1526843qcv.32
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 01:34:48 -0700 (PDT)
In-Reply-To: <CAJZOPZKGGj=531UVDw-47mWD7LGQ7AYh1c7cZwv_08p0Lz1Gtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> John Fastabend <john.r.fastabend@intel.com> wrote:
> > It does seem unfortunate though that every time we want a feature that
> > already exists to be applicable for a VF we have to go through this
> > exercise of adding an ndo op and adding lookup code in each and
> > every driver to find the VF and pass messages back and forth.
>
> agree, how about introducing ndo_set_vf_config which we can extend to
> include new attrbiutes each time we want to add them...  actually do
> we have robust way to extend the existing ifla_vf_info? I guess so
>
> int (*ndo_get_vf_config)(struct net_device *dev, int vf, struct ifla_vf_info *ivf);

Do we lean towards introducing new call/s to set/get VF config and can
be extended to new features as they come  - e.g
control VF link state, read VF packet/byte counters, set vlan egress
map for the VF when its in VGT mode, etc, or
stick to the current method of one ndo per need?


>
> these two calls are also there but only the enic driver uses them
>
> int (*ndo_set_vf_port)(struct net_device *dev, int vf, struct nlattr *port[]);
> int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
