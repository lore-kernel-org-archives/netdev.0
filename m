From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Mon, 26 Apr 2010 15:38:57 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755A3BE8B8F@orsmsx508.amr.corp.intel.com>
References: <C7FB3747.2BAAA%scofeldm@cisco.com>
 <C7FB3E22.2BAEE%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Scott Feldman <scofeldm@cisco.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27036 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755412Ab0DZWjD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 18:39:03 -0400
In-Reply-To: <C7FB3E22.2BAEE%scofeldm@cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Scott Feldman
>Sent: Monday, April 26, 2010 12:57 PM
>To: Scott Feldman; David Miller
>Cc: netdev@vger.kernel.org; chrisw@redhat.com; arnd@arndb.de
>Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
>
>On 4/26/10 12:27 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:
>> We'd need an array of struct ifla_vf_port_profile hanging off of
>netdev, one
>> element for each VF.  That seems like a lot of mem hanging off of
>netdev,
>> and we'd have to define a MAX_VF to size the array.  How about a
>> ndo_get_vf_port_profile() that the netdev fills in, and the netdev
>keeps the
>> data in it's private area?  That's how ndo_get_vf_config() is working.
>
>Hmmm....even that isn't so nice because the port-profile info for all
>VFs is
>going to get stuffed into the RTM_GETLINK skb, and I assume there are
>limits
>on the skb return size.
>
>Here's a proposal:
>
>Currently we have RTM_GETLINK for
>
>    ip link show [ DEVICE ]
>
>This dumps everything for the DEVICE including info for each VF.  Let's
>modify RTM_GETLINK to look like this:
>
>    ip link show [ DEVICE [ vf NUM] ]
>
>If you don't give the optional vf NUM you get base dump on DEVICE.  If
>you
>give vf NUM, you get the VF-specific dump.  This scales much better with
>the
>number of VFs.
>
>(Number of VFs can easily be > 128 in some designs).
>
>Comments?

It seems to me that this:

ip link show [ DEVICE ]

should at least return the number of VFs so
that you can make sure the subsequent usage of this:

ip link show [ DEVICE [ vf NUM ] ]

is still in range with the [ vf NUM ] parameter.  Otherwise you wouldn't know
what the range of NUM is.

Other than that I can see why you would want to limit the size of the dump
when using 'ip link show [ DEVICE ]'.

- Greg

