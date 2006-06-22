From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 11/21] e1000: disable CRC stripping workaround
Date: Thu, 22 Jun 2006 17:57:08 +0200
Message-ID: <20060622155708.GA27267@xi.wantstofly.org>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052029.25497.67575.stgit@gitlost.site> <449A2B20.2020006@candelatech.com> <4807377b0606220839i5de14797ocb9e404fd21540e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:6826 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751833AbWFVP5K
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 11:57:10 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Disposition: inline
In-Reply-To: <4807377b0606220839i5de14797ocb9e404fd21540e3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 08:39:10AM -0700, Jesse Brandeburg wrote:

> >> CRC stripping is breaking SMBUS-connected BMC's. We disable this
> >> feature to make it work. This fixes related bugs regarding SOL.
> >
> >Shouldn't you also have to subtract 4 bytes when setting the skb len
> >in the receive logic?  Perhaps when setting the rx-bytes counter as well?
> 
> we thought about this, but most drivers don't strip the CRC,

Really?


> and we couldn't find any tests including bridging that cared if the
> CRC was there in the indicated packet.

Bridging definitely cares -- some years ago there was a case where
8139too NICs would pass packets up the stack with 4 bytes of FCS, and
that causes frames received on 8139too interfaces not to be forwarded
to other interfaces because on TX, the frame would be too long.

Maybe e1000 is okay with sending oversized frames, but other NIC
drivers might not be.

(Did you test without bridge-netfilter enabled?  bridge-nf might trim
incoming IP packets even in the bridging case.)


cheers,
Lennert
