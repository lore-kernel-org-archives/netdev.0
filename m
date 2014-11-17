From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 01/14] net: provide a per host RSS key generic
 infrastructure
Date: Sun, 16 Nov 2014 22:58:41 -0800
Message-ID: <1416207521.31801.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-2-git-send-email-edumazet@google.com>
	 <87wq6uiass.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:44879 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbaKQG6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 01:58:39 -0500
Received: by mail-ie0-f171.google.com with SMTP id rl12so834763iec.30
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 22:58:38 -0800 (PST)
In-Reply-To: <87wq6uiass.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-16 at 22:46 -0800, Andi Kleen wrote:

> Wouldn't it be better to have some kernel facility to query on what
> port a given mapping would end up rather than exporting
> the key? Similar to querying the rounting table.
> That would be more abstract.

It is already there, few drivers implement

ethtool -x eth0

And all users can read rss key :

$ ethtool -x eth0
RX flow hash indirection table for eth0 with 8 RX ring(s):
    0:      0     1     2     3     4     5     6     7
RSS hash key:
d9:73:69:1e:c5:74:73:38:67:a4:a9:98:78:b1:e2:b6:39:1c:02:f9:30:57:79:84:02:b7:48:90:63:95:10:85:51:bb:f2:9e:f2:c5:85:27

> 
> > +	{
> > +		.procname	= "netdev_rss_key",
> > +		.data		= &netdev_rss_key,
> > +		.maxlen		= sizeof(int),
> > +		.mode		= 0444,
> 
> Surely 0400 ? After all it's a kind a "secret"

Not really. Toeplitz is not cryptographic. A local program can easily
rebuild the key even if kept 'secret' by networking stack.
