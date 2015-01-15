From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/5] vxlan: Group Policy extension
Date: Thu, 15 Jan 2015 01:28:04 +0000
Message-ID: <20150115012804.GI2105@casper.infradead.org>
References: <cover.1421280226.git.tgraf@suug.ch>
 <c73939bbb55a8e450de7931d830e0467a8340665.1421280226.git.tgraf@suug.ch>
 <CA+mtBx-CH2=D-wKmkjVTvhQOWhbf73NxcGrXrXOPE-E2PzJajQ@mail.gmail.com>
 <20150115002323.GH2105@casper.infradead.org>
 <CA+mtBx9=coY1YwPn2ds66PD-J7FDaN_3Yf-_nB_vUEeZEDyJdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.ne>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34786 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbbAOB2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 20:28:06 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx9=coY1YwPn2ds66PD-J7FDaN_3Yf-_nB_vUEeZEDyJdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 05:08pm, Tom Herbert wrote:
> On Wed, Jan 14, 2015 at 4:23 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > Because we need to compare enabled extensions in vxlan_find_sock() to
> > make sure we are not sharing a VXLAN socket with extensions enabled
> > with a user which does not have the same extensions enabled.
> >
> > However, we do not want vxlan_find_sock() to compare all flags.
> >
> > So we need a bitmap that is ignored during the share check (flags) and
> > a bitmap that must match to allow sharing (exts).
> >
> > The RCO extension is currently suffering from this bug which is causing
> > a compatibility issue. I explained in the thread of your patch. I was
> > under the imrpession that you would either send a v2 or fix it in a
> > follow-up.
> 
> As I mentioned, we would also need to match receive checksum settings
> which is not appropriately called an extension. A mask of interesting
> flags could be used to do the comparison in vxlan_find_sock.

What exactly is the problem of having a distinct bitmap used by
extensions? It is the least error prone method because it's clear that
all extensions must match and we don't have to maintain an additional
bitmask which can be forgotten to be updated.

If you need to compare additional receive checksum settings for RCO
then that should be separate because as you say it's not an extension.
