From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH net-next 2/2] liquidio: Add support to create management
 interface
Date: Mon, 31 Jul 2017 18:58:28 -0700
Message-ID: <20170801015828.GA1449@felix-thinkpad.cavium.com>
References: <20170717195046.GA1191@felix-thinkpad.cavium.com>
 <20170717195217.GA1222@felix-thinkpad.cavium.com>
 <20170718115827.7bd737f2@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, veerasenareddy.burru@cavium.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0080.outbound.protection.outlook.com ([104.47.34.80]:45856
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751201AbdHAB6w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 21:58:52 -0400
Content-Disposition: inline
In-Reply-To: <20170718115827.7bd737f2@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 11:58:27AM -0700, Jakub Kicinski wrote:
> On Mon, 17 Jul 2017 12:52:17 -0700, Felix Manlunas wrote:
> > From: VSR Burru <veerasenareddy.burru@cavium.com>
> > 
> > This patch adds support to create a virtual ethernet interface to
> > communicate with Linux on LiquidIO adapter for management.
> > 
> > Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
> > Signed-off-by: Srinivasa Jampala <Srinivasa.Jampala@cavium.com>
> > Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> > Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> > Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> 
> Not my call, but I have mixed feelings about this one.  Is there any
> precedent under drivers/net/ethernet of exposing special communication
> channels with FW like this?  It's irrelevant to me that you're running
> SSH, arbitrary communication with FW from userspace is not something
> netdev community usually accepts.  And I'm afraid what the effects will
> be of this getting accepted.  I'm pretty sure most modern network
> adapters have management CPU cores perfectly capable of running Linux.
> I know NFP does, here is the out-of-tree code equivalent to this patch:

LiquidIO is committed to ethtool and we are not trying to force users to
use this communication channel in place of ethtool. This communication
channel is for our field debug and informattion purposes and not for end
users. If most modern network adapters have management cores that can
run Linux, we could probably also think of finding a standard way to
talk to that Linux.

> 
> https://github.com/Netronome/nfp-drv-kmods/blob/master/src/nfpcore/nfp_net_vnic.c
> 
> I'm not looking forward to a world where I have to ssh into my NIC and
> run vendor commands to configure things.

We are not asking users to ssh into card and run vendor commands. Users
of LiquidIO card will continue to use ethtool for configuration. This is
for our field debugging where we would like to login to the linux and be
able to know the status of different hardware blocks in the card.
