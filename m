From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: RE: RFC: rtnetlink problems with Cisco enic and VFs
Date: Wed, 23 Apr 2014 02:33:06 +0000
Message-ID: <6CE81A2095B0024BBC77007BD04E553823E87A41@xmb-aln-x02.cisco.com>
References: <20140423092606.c73425b64d127b8f94469fcb@redhat.com>
	<20140422170438.00006b45@unknown>
	<20140423111203.3e8cf3a9a12acb1d95b3635a@redhat.com>
 <20140422.211642.1908374698598409144.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregory.v.rose@intel.com" <gregory.v.rose@intel.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sujith Sankar (ssujith)" <ssujith@cisco.com>,
	"govindarajulu90@gmail.com" <govindarajulu90@gmail.com>,
	"Neel Patel (neepatel)" <neepatel@cisco.com>,
	"nistrive@cisco.com" <nistrive@cisco.com>
To: David Miller <davem@davemloft.net>,
	"dgibson@redhat.com" <dgibson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-6.cisco.com ([173.37.142.93]:38517 "EHLO
	alln-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaDWCdI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 22:33:08 -0400
In-Reply-To: <20140422.211642.1908374698598409144.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: Tuesday, April 22, 2014 6:17 PM
> To: dgibson@redhat.com
> Cc: gregory.v.rose@intel.com; ben@decadent.org.uk;
> netdev@vger.kernel.org; Christian Benvenuti (benve); Sujith Sankar
> (ssujith); govindarajulu90@gmail.com; Neel Patel (neepatel);
> nistrive@cisco.com
> Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
> 
> From: David Gibson <dgibson@redhat.com>
> Date: Wed, 23 Apr 2014 11:12:03 +1000
> 
> > And therein lies the problem.  I don't even know what the
> > IFLA_VF_PORTS info is for, but presumably something uses it.  If they
> > stop receiving it, they can be expected to break horribly.

In the case of Enic, libvirt uses IFLA_VF_PORTS in the context of the port profile
(see virtualport section and 802.1Qbh in the libvirt network xml documentation).

As Miller said, libvirt and iproute2 are the two known users (with libvirt being the main one)
but you never know what else may be using it.

> We did the same thing to VFINFO list.

I guess you refer to Bugzilla 889319.

> All the users I could find already set the mask unconditionally for all device
> dumps.
> 
> It's absolutely, positively, the only reasonable fix for this problem.

The fix based on IFLA_EXT_MASK seems reasonable to me
(IFLA_EXT_MASK is in use in libvirt >= 1.0.3 and iproute2 >=3.4.0 based on a quick check).

/Chris
