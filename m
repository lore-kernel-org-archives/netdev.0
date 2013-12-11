From: "Jan Beulich" <JBeulich@suse.com>
Subject: RE: [Xen-devel] [PATCH net v5] xen-netback: fix fragment
 detection in checksum setup
Date: Wed, 11 Dec 2013 07:27:02 +0000
Message-ID: <52A821D6020000780010C279@nat28.tlf.novell.com>
References: <1386092369-13618-1-git-send-email-paul.durrant@citrix.com>
 <52A74B56020000780010BFB9@nat28.tlf.novell.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD01ACF1F@AMSPEX01CL01.citrite.net>
 <52A75645020000780010C01B@nat28.tlf.novell.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD01AD196@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	"Zoltan Kiss" <zoltan.kiss@citrix.com>,
	"David Miller" <davem@davemloft.net>,
	"xen-devel" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Paul Durrant" <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:38448 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab3LKH1G convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Wed, 11 Dec 2013 02:27:06 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD01AD196@AMSPEX01CL01.citrite.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 10.12.13 at 18:29, Paul Durrant <Paul.Durrant@citrix.com> wrote:
>> Another question: Don't the skb_partial_csum_set() calls require
>> the respective pulls to have happened already?
>> 
> 
> I'm not aware of that requirement. There's no specific comment to that 
> effect that I can see and the code suggests that we only need to have pulled 
> up as far as the end of the checksum location itself.

Which we didn't - the previous pull only covered the IP header (and
in the IPv4 case even thereof only the basic, fixed size part).

Jan
