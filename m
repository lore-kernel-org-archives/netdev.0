From: "Jan Beulich" <JBeulich@suse.com>
Subject: RE: [Xen-devel] [PATCH] xen-netback: correct return value
 checks on xenbus_scanf()
Date: Thu, 07 Jul 2016 06:21:18 -0600
Message-ID: <577E655E02000078000FC358@prv-mh.provo.novell.com>
References: <577E277C02000078000FBEBB@prv-mh.provo.novell.com>
 <577E27B8.2050603@citrix.com> <20160707103513.GB416@citrix.com>
 <577E32BF.9050007@citrix.com>
 <d0df3b813db94858ab608bd33216c2d9@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Vrabel" <david.vrabel@citrix.com>,
	"Paul Durrant" <Paul.Durrant@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:50798 "EHLO
	prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbcGGMVT convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:3:1>);
	Thu, 7 Jul 2016 08:21:19 -0400
In-Reply-To: <d0df3b813db94858ab608bd33216c2d9@AMSPEX02CL03.citrite.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 07.07.16 at 12:55, <Paul.Durrant@citrix.com> wrote:
>>  -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of David Vrabel
>> Sent: 07 July 2016 11:45
>> To: Wei Liu; David Vrabel
>> Cc: xen-devel@lists.xenproject.org; Jan Beulich; netdev@vger.kernel.org 
>> Subject: Re: [Xen-devel] [PATCH] xen-netback: correct return value checks
>> on xenbus_scanf()
>> 
>> On 07/07/16 11:35, Wei Liu wrote:
>> > On Thu, Jul 07, 2016 at 10:58:16AM +0100, David Vrabel wrote:
>> >> On 07/07/16 08:57, Jan Beulich wrote:
>> >>> Only a positive return value indicates success.
>> >>
>> >> This is not correct.
>> >>
>> >
>> > Do you mean the commit message is not correct or the code is not
>> > correct? If it is the formal, do you have any suggestion to fix it?
>> 
>> This code is correct as-is, thus the commit message is wrong or misleading.
> 
> Is that true? Jan is correct in saying that only >0 is an indicator of 
> success according to the usual semantics of sccanf().

As was correctly pointed out, xenbus_scanf(), other than scanf(),
can't return zero right now (which I think has corner cases where
this might be a problem). So if I would get the feeling that a
correction (benign or not at this point in time) would be accepted,
what about "Only a positive return value is guaranteed to indicates
success" as commit description?

> Personally I think the 
> code would be clearer if the checks for failure were < 1 rather than <= 0.

I'd be fine with that, albeit if comparing with any non-zero number
then I think it would better be == or != instead of < or <=.

Jan
