From: Brian Russell <brian.russell@brocade.com>
Subject: Re: [PATCH net-next v3 0/3] NSH and VxLAN-GPE
Date: Fri, 4 Mar 2016 15:38:47 +0000
Message-ID: <56D9AC07.4010601@brocade.com>
References: <1456830709-32052-1-git-send-email-brussell@brocade.com>
 <20160301181231.GA95346@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Brian Russell <brussell@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:41375 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757486AbcCDPi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 10:38:58 -0500
In-Reply-To: <20160301181231.GA95346@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/03/16 18:12, Alexei Starovoitov wrote:
> On Tue, Mar 01, 2016 at 11:11:46AM +0000, Brian Russell wrote:
>> These patches add a new module to support encap/decap of Network
>> Service Header (NSH) as defined in:
>>
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__tools.ietf.org_html_draft-2Dietf-2Dsfc-2Dnsh-2D01&d=CwIBAg&c=IL_XqQWOjubgfqINi2jTzg&r=Doie302MT-sezztwQymkPQ3_4X5Q3a0mKbiZzzoNm-0&m=GXnpiqS7PmfkgZFQ49KQrVhoa7H-hyPyPstkZdCi7hQ&s=Ncdq5xpzX-AAUeSDXaoU_zxqfXSdoI_qvgFZVyUclV0&e= 
>>
>> Both NSH Type 1 and Type 2 metadata are supported with a simple registration
>> hook to allow listeners to register to see packets with Type 1 or a specific
>> class of Type 2 metadata. NSH could be added to packets sent over a variety
>> of link types, eg. VxLAN, GRE, ethernet.
>>
>> v2 - fix copyright notices and tidy up use of types
>>
>> v3 - fix various style issues in nsh module
>>      remove VxLAN-GPE changes
>>      add nsh logging module as example
>>      add nsh netfilter encap target as example
> 
> two fake examples are trying to justify EXPORT_SYMBOL(nsh_register_listener) ?!
> what's the real meaning of this patch set?
> As far as I can see in-tree users cannot do anything useful with it.
> 

I don't see what you're getting at. I thought the "real meaning" was obvious?

The NSH draft says:

" Optional Variable Length Metadata

...
   TLV Class: describes the scope of the "Type" field.  In some cases,
   the TLV Class will identify a specific vendor, in others, the TLV
   Class will identify specific standards body allocated types.  A new
   IANA registry will be created for TLV Class type.

   Type: the specific type of information being carried, within the
   scope of a given TLV Class.  Value allocation is the responsibility
   of the TLV Class owner."

So it seems reasonable to have a hook to hang metadata interpretation on?

Thanks and regards,

Brian
