From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: RE: [PATCH 1/1] iproute2: v3: Add support to configure SR-IOV VF
 minimum and maximum Tx rate through ip tool.
Date: Mon, 28 Apr 2014 09:10:13 +0000
Message-ID: <290BEC245535C3449143D5D84900EEF78CE1CC79@avmb3.qlogic.org>
References: <1397450220-8269-1-git-send-email-sucheta.chakraborty@qlogic.com>
 <20140422154051.26e584ce@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-HSG Linux NIC Dev <Dept-HSGLinuxNICDev@qlogic.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"gregory.v.rose@intel.com" <gregory.v.rose@intel.com>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"Ariel Elior" <Ariel.Elior@qlogic.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"mkubecek@suse.cz" <mkubecek@suse.cz>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46298 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752895AbaD1JKm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 05:10:42 -0400
In-Reply-To: <20140422154051.26e584ce@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, April 23, 2014 4:11 AM
> To: Sucheta Chakraborty
> Cc: netdev; Dept-HSG Linux NIC Dev; ben@decadent.org.uk;
> gregory.v.rose@intel.com; linux-net-drivers@solarflare.com; Ariel
> Elior; amirv@mellanox.com; mkubecek@suse.cz
> Subject: Re: [PATCH 1/1] iproute2: v3: Add support to configure SR-IOV
> VF minimum and maximum Tx rate through ip tool.
> 
> On Mon, 14 Apr 2014 00:37:00 -0400
> Sucheta Chakraborty <sucheta.chakraborty@qlogic.com> wrote:
> 
> > o "min_tx_rate" option has been added for minimum Tx rate. Hence, for
> >   consistent naming, "max_tx_rate" option has been introduced for
> maximum
> >   Tx rate.
> >
> > o Change in v2: "rate" can be used along with "max_tx_rate".
> >   When both are specified, "max_tx_rate" should override.
> >
> > o Change in v3:
> >   * IFLA_VF_RATE: When IFLA_VF_RATE is used, and user has given only
> one of
> >     min_tx_rate or max_tx_rate, reading of previous rate limits is
> done in
> >     userspace instead of in kernel space before ndo_set_vf_rate.
> >
> >   * IFLA_VF_TX_RATE: When IFLA_VF_TX_RATE is used, min_tx_rate is
> always read
> >     in kernel space. This takes care of below scenarios:
> >     (1) when old tool sends "rate" but kernel is new (expects min and
> max)
> >     (2) when new tool sends only "rate" but kernel is old (expects
> > only "rate")
> >
> > Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> 
> I like the concept fine, but the general policy of ip route commands is
> that the output format should match the input (except for statistics).
> 
> This (and ther earlier tx_rate patch are printing values in a different
> format than the input
> 
> i.e don't print:
> 	max tx rate 110 (Mbps)
> instead print:
> 	max_tx_rate 110Mbps
> 
> 
With this change display would be as below:

vf 0 MAC 3e:a0:ca:bd:ae:5a, tx rate 300 (Mbps), max_tx_rate 300Mbps,
    min_tx_rate 200Mbps

I did not change tx rate option to maintain backward compatibility.

Is the output valid?

Thanks,
Sucheta.
