From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 hw csum failure
Date: Tue, 15 Nov 2011 09:45:16 -0800
Message-ID: <20111115094516.3eb54a1a@nehalam.linuxnetplumber.net>
References: <CAM1AHpSuruDx3CxzK=Med0iyxxwu7wxgRZib7yhBMiCVKXqzeA@mail.gmail.com>
	<4EC23EE7.2010606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Martin Volf <martin.volf.42@gmail.com>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"wcang@sfc.wide.ad.jp" <wcang@sfc.wide.ad.jp>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55221 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757020Ab1KORp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 12:45:27 -0500
In-Reply-To: <4EC23EE7.2010606@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Nov 2011 18:28:55 +0800
"Yan, Zheng" <zheng.z.yan@intel.com> wrote:

> I re-tested the checksum code, both CHECKSUM_NONE and CHECKSUM_COMPLETE
> cases are OK. Maybe the bug is related to sky2.
> 
> Regards
> Yan, Zheng

There are three types of receive checksumming:
  1. Hardware does not do checksumming (CHECKSUM_NONE)
  2. Hardware validates checksum (CHECKSUM_UNNECESSARY)
  3. Hardware computes sum of bytes in skb (CHECKSUM_COMPLETE)

Most hardware does #2, but sky2 uses #3.
For the second case, the hardware does not look at headers but only
reports the one's complement value in ip_summed. It is up to the
protocol layers to adjust accordingly.  This means if data is removed
or added the checksum needs to be adjusted.
