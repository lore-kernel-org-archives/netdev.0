From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/4] xen-netfront: drop skb when skb->len
 > 65535
Date: Tue, 19 Mar 2013 13:40:45 +0000
Message-ID: <51486ADD.5050603@citrix.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>	 <1363602955-24790-3-git-send-email-wei.liu2@citrix.com>	 <51471AAC.2050509@citrix.com>	 <1363614500.30193.47.camel@zakaz.uk.xensource.com>	 <51471DE0.9060506@citrix.com> <1363616388.29093.201.camel@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:21473 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755332Ab3CSNlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 09:41:17 -0400
In-Reply-To: <1363616388.29093.201.camel@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/03/13 14:19, Wei Liu wrote:
> On Mon, 2013-03-18 at 14:00 +0000, David Vrabel wrote:
>> On 18/03/13 13:48, Ian Campbell wrote:
>>> On Mon, 2013-03-18 at 13:46 +0000, David Vrabel wrote:
>>>> On 18/03/13 10:35, Wei Liu wrote:
>>>>> The `size' field of Xen network wire format is uint16_t, anything bigger than
>>>>> 65535 will cause overflow.
>>>>
>>>> The backend needs to be able to handle these bad packets without
>>>> disconnecting the VIF -- we can't fix all the frontend drivers.
>>>
>>> Agreed, although that doesn't imply that we shouldn't fix the frontend
>>> where we can -- such as upstream as Wei does here.
>>
>> Yes, frontends should be fixed where possible.
>>
>> This is what I came up with for the backend.  I don't have time to look
>> into it further but, Wei, feel free to use it as a starting point.
>>
> 
> Thanks for this patch.
> 
> I haven't gone through XSA-39 discussion, this is why I didn't come up
> with a fix for backend -- I need to make sure dropping packet like this
> won't re-exhibit the security hole.

How are these overlarge packets generated?  How do you reproduce the issue?

David
