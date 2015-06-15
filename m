From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bridge: use either ndo VLAN ops or
 switchdev VLAN ops to install MASTER vlans
Date: Mon, 15 Jun 2015 16:03:04 -0700 (PDT)
Message-ID: <20150615.160304.754449308616141621.davem@davemloft.net>
References: <1434155990-45616-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp, roopa@cumulusnetworks.com,
	jhs@mojatatu.com, simon.horman@netronome.com,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbbFOXDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:03:05 -0400
In-Reply-To: <1434155990-45616-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Fri, 12 Jun 2015 17:39:50 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> v2:
> 
> Move struct switchdev_obj automatics to inner scope where there used.
> 
> v1:
> 
> To maintain backward compatibility with the existing iproute2 "bridge vlan"
> command, let bridge's setlink/dellink handler call into either the port
> driver's 8021q ndo ops or the port driver's bridge_setlink/dellink ops.
> 
> This allows port driver to choose 8021q ops or the newer
> bridge_setlink/dellink ops when implementing VLAN add/del filtering on the
> device.  The iproute "bridge vlan" command does not need to be modified.
> 
> To summarize using the "bridge vlan" command examples, we have:
> 
> 1) bridge vlan add|del vid VID dev DEV
> 
> Here iproute2 sets MASTER flag.  Bridge's bridge_setlink/dellink is called.
> Vlan is set on bridge for port.  If port driver implements ndo 8021q ops,
> call those to port driver can install vlan filter on device.  Otherwise, if
> port driver implements bridge_setlink/dellink ops, call those to install
> vlan filter to device.  This option only works if port is bridged.
> 
> 2) bridge vlan add|del vid VID dev DEV master
> 
> Same as 1)
> 
> 3) bridge vlan add|del vid VID dev DEV self
> 
> Bridge's bridge_setlink/dellink isn't called.  Port driver's
> bridge_setlink/dellink is called, if implemented.  This option works if
> port is bridged or not.  If port is not bridged, a VLAN can still be
> added/deleted to device filter using this variant.
> 
> 4) bridge vlan add|del vid VID dev DEV master self
> 
> This is a combination of 1) and 3), but will only work if port is bridged.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied.
