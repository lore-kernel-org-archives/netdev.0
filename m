From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Wed, 7 Jan 2015 08:56:31 -0800
Message-ID: <CA+mtBx_A_M3+irq7w4nNCyPZBgM7ja+wfJT4w4Q0Yo6GMGYVgA@mail.gmail.com>
References: <cover.1420594925.git.tgraf@suug.ch>
	<2b43c19c47e3702b370054f8fd11233e44179edf.1420594925.git.tgraf@suug.ch>
	<CA+mtBx_Jj-tUM1nbHd2fHb0-=QpK3tcQgA=smWmg=cB-fupdGg@mail.gmail.com>
	<20150107162129.GQ21820@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34584 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbbAGQ4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 11:56:32 -0500
Received: by mail-ie0-f174.google.com with SMTP id at20so4719377iec.5
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 08:56:31 -0800 (PST)
In-Reply-To: <20150107162129.GQ21820@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 8:21 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/07/15 at 08:05am, Tom Herbert wrote:
>> Associating a sixteen bit field with security is worrisome, especially
>> considering that VXLAN provides no verification for any header fields
>> and doesn't even advocate use of outer UDP checksum so the field is
>> susceptible to an undetected single bit flip. The concept of a
>> "trusted underlay" is weak justification and hardly universal, so the
>> only way to actually secure this is through IPsec (this is mentioned
>> in the VXLAN-GPB draft).
>
> As you state correctly, this work requires a trusted underlay which can
> be achieved with IPsec, OpenVPN, SSH, ...
>
This can't be enforced. There's already a lot of deployment of VXLAN
in non-trusted networks, and there's nothing to prevent someone from
using this feature in those environments. Maybe there's an argument
that VXLAN already fundamentally lacks security and verification, so
adding this field might not make things worse :-/.

>> But if we have the security state of IPsec then why would we need
>> this field anyway?
>
> It's a separation of concern: the security label mechanism of the
> overlay should not depend on an eventual encryption layer in the
> underlay as not all of them provide a mechanism to label packets.
>
>> Could this same functionality be achieved if we just match the VNI to
>> a mark in IP tables?
>
> If the VNI is not already used for another purpose, yes. The solution
> as proposed can be integrated into existing VXLAN overlays separated by
> VNI. It is also compatible with hardware VXLAN VTEPs which ignore the
> reserved bits while continueing to maintain VNI separation.

It seems like it should be relatively easy to group VNIs together to
have the same mark with the current use of VNI. The works up to the
point that all packets corresponding to a single VNI get the same
mark.

Tom
