From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net 1/2] sh_eth: Fix promiscuous mode on chips without
 TSU
Date: Mon, 19 Jan 2015 10:45:32 +0000
Message-ID: <1421664332.1222.204.camel@xylophone.i.decadent.org.uk>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
	 <1421430672.1222.191.camel@xylophone.i.decadent.org.uk>
	 <54B9663D.2040008@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ct178-internal@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:44593 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbASKpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 05:45:35 -0500
In-Reply-To: <54B9663D.2040008@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-16 at 22:27 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/16/2015 08:51 PM, Ben Hutchings wrote:
> 
> > Currently net_device_ops::set_rx_mode is only implemented for
> > chips with a TSU (multiple address table).  However we do need
> > to turn the PRM (promiscuous) flag on and off for other chips.
> 
> > - Remove the unlikely() from the TSU functions that we may safely
> >    call for chips without a TSU
> 
>     This is just optimization, worth pushing thru net-next instead.

This patch introduces calls to those functions for chips without a TSU,
and that makes the branch hint no longer correct.  (Not that these
functions are speed-critical, so it doesn't matter that much.)

> > - Make setting of the MCT flag conditional on the tsu capability flag
> > - Rename sh_eth_set_multicast_list() to sh_eth_set_rx_mode() and plumb
> >    it into both net_device_ops structures
> > - Remove the previously-unreachable branch in sh_eth_rx_mode() that
> >    would otherwise reset the flags to defaults for non-TSU chips
> 
>     It couldn't be default for non-TSU chips, they don't seem to have 
> ECMR.MCT. So it was just wrong.
> 
>     It would have been better if you did one thing per patch or at least 
> didn't mix fixes with clean-ups...
[...]

I think this is one logical change.

Ben.
