From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC iproute2] Add VF link state control
Date: Wed, 8 May 2013 20:31:13 +0300
Message-ID: <CAJZOPZKGGj=531UVDw-47mWD7LGQ7AYh1c7cZwv_08p0Lz1Gtg@mail.gmail.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>
	<1368020717-22194-4-git-send-email-ogerlitz@mellanox.com>
	<20130508091753.0be79e6c@nehalam.linuxnetplumber.net>
	<1368030286.1664.16.camel@dcbw.foobar.com>
	<518A80F6.5060605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Rony Efraim <ronye@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:59966 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756904Ab3EHRbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 13:31:16 -0400
Received: by mail-qa0-f45.google.com with SMTP id hu16so2914217qab.18
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 10:31:13 -0700 (PDT)
In-Reply-To: <518A80F6.5060605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 8, 2013 at 7:44 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> It does seem unfortunate though that every time we want a feature that
> already exists to be applicable for a VF we have to go through this
> exercise of adding an ndo op and adding lookup code in each and
> every driver to find the VF and pass messages back and forth.

agree, how about introducing ndo_set_vf_config which we can extend to
include new attrbiutes each time we want to add them...  actually do
we have robust way to extend
the existing ifla_vf_info? I guess so

int (*ndo_get_vf_config)(struct net_device *dev, int vf, struct
ifla_vf_info *ivf);

these two calls are also there but only the enic driver uses them

int (*ndo_set_vf_port)(struct net_device *dev, int vf, struct nlattr *port[]);
int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
