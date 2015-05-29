From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] xen-netfront sets partial checksum at wrong
 offset
Date: Fri, 29 May 2015 11:50:26 +0100
Message-ID: <55686092020000780007EF4F@mail.emea.novell.com>
References: <ee74926e-deb3-4cbc-9798-42c19f4fe219@default>
 <20150511150827.GA23561@l.oracle.com>
 <3a08e270-3a70-417b-9ab8-439c7cdc1eb2@default>
 <55685CBF020000780007EEF8@mail.emea.novell.com>
 <20150529103916.GY30474@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	"Konrad Wilk" <konrad.wilk@oracle.com>,
	"Venkat Venkatsubra" <venkat.x.venkatsubra@oracle.com>,
	<netdev@vger.kernel.org>
To: <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emea.novell.com ([130.57.118.101]:51358 "EHLO
	mail.emea.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489AbbE2Ku1 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Fri, 29 May 2015 06:50:27 -0400
In-Reply-To: <20150529103916.GY30474@zion.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 29.05.15 at 12:39, <wei.liu2@citrix.com> wrote:
> On Fri, May 29, 2015 at 11:34:07AM +0100, Jan Beulich wrote:
>> >>> On 11.05.15 at 19:25, <venkat.x.venkatsubra@oracle.com> wrote:
>> >>  
>> >> Please CC the maintainers of the driver. You can get that from
>> >> 'scripts/get_maintainer.pl'
>> >> 
>> >> I've done that for you.
>> > 
>> > Thanks, Konrad.
>> > 
>> > I am copying Wei too who had fixed the below problem earlier.
>> > It fixed the incorrect ip_hdr(). tcp_hdr() still needs to fixed.
>> > 
>> > commit d554f73df6bc35ac8f6a65e5560bf1d31dfebed9
>> > Author: Wei Liu <wei.liu2@citrix.com>
>> > Date:   Wed Feb 19 18:48:34 2014 +0000
>> > 
>> >     xen-netfront: reset skb network header before checksum
>> 
>> So no response at all so far from the maintainers made me look into
>> this: I first thought what we need would be calls to
>> skb_probe_transport_header() in skb_checksum_setup_ip() after
>> each of the skb_maybe_pull_tail() functions. But
>> skb_partial_csum_set() already calls skb_set_transport_header(),
>> so I now think things ought to be fine without any change. Can
>> you clarify what you think is missing? Or is this an issue in just the
>> old (3.8.x) kernel you're using?
>> 
> 
> I think this is the follow-up thread <20150512013424.GA7960@oracle.com>
> 
> And the conclusion is 3.8 is too old so the fix is not there.

Ah, right. Seems like I failed to remove the earlier mail from my list of
things to look at when this came through. Sorry for the noise then.

Jan
