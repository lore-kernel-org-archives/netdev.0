From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [patch 1/4] drivers/net/ethernet/ibm/ehea/ehea_main.c: add alias
 entry for portN properties
Date: Mon, 16 Sep 2013 18:01:41 -0300
Message-ID: <20130916210141.GB14221@oc0268524204.ibm.com>
References: <20130913215201.6501131C1BF@corp2gmr1-1.hot.corp.google.com>
 <20130913.195857.1842211951469893139.davem@davemloft.net>
 <20130916205543.GA14221@oc0268524204.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	ohering@suse.com, jeffm@suse.com, jslaby@suse.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:50937 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347Ab3IPVBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 17:01:49 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 16 Sep 2013 18:01:45 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id D56F71DC0066
	for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 17:01:43 -0400 (EDT)
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8GKuir63068080
	for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 17:56:44 -0300
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8GL1hx4024910
	for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 18:01:43 -0300
Content-Disposition: inline
In-Reply-To: <20130916205543.GA14221@oc0268524204.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 05:55:43PM -0300, Thadeu Lima de Souza Cascardo wrote:
> On Fri, Sep 13, 2013 at 07:58:57PM -0400, David Miller wrote:
> > From: akpm@linux-foundation.org
> > Date: Fri, 13 Sep 2013 14:52:01 -0700
> > 
> > > From: Olaf Hering <ohering@suse.com>
> > > Subject: drivers/net/ethernet/ibm/ehea/ehea_main.c: add alias entry for portN properties
> > > 
> > > Use separate table for alias entries in the ehea module, otherwise the
> > > probe() function will operate on the separate ports instead of the
> > > lhea-"root" entry of the device-tree
> > > 
> > > Addresses https://bugzilla.novell.com/show_bug.cgi?id=435215
> > > 
> > > Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> > > Signed-off-by: Olaf Hering <ohering@suse.com>
> > > Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> > > Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> > > Cc: "David S. Miller" <davem@davemloft.net>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > This can definitely have consequences and in particular potentially cause
> > a device to not get probed properly.
> > 
> > Therefore I want an ehea driver maintainer to review and ACK this before
> > I apply it.
> > 
> > Thanks.
> > 
> 
> After taking a glance at the patch, it doesn't seem to change probing,
> since it keeps the same table for the driver itself. It seems this only
> changes alias, so the driver will be loaded under some device-tree
> layouts not currently matched by the current alias.
> 
> That last part is the one that bothers me. I still need to find a system
> where the current modalias won't work and this patch is needed. I'll see
> if I can put more effort into that and find a system as described in the
> bug.
> 
> Regards.
> Thadeu Cascardo.

Sorry for the noise. I just checked again the bug, and had to read
between the lines that this issue might happen with the generation of
initrd, when the scripts check for /sys/class/net/eth0/device/modalias,
which links to the port device at
/sys/devices/ibmebus/23c00400.lhea/port0/.

I think that should be clarified in the log message. Besides that, since
this has also been in the field for a long time:

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Regards.
Cascardo.
