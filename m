From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Wed, 7 Jan 2015 11:10:48 +0000
Message-ID: <20150107111048.GP21820@casper.infradead.org>
References: <CAADnVQ+EO34qYbK+sji-Da3CMkn+-V-9Uvdar_WgxRQ4_+JFXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33256 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbbAGLKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 06:10:49 -0500
Content-Disposition: inline
In-Reply-To: <CAADnVQ+EO34qYbK+sji-Da3CMkn+-V-9Uvdar_WgxRQ4_+JFXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/15 at 07:37pm, Alexei Starovoitov wrote:
> Even it works ok, I think this struct layout is ugly.
> imo would be much easier to read if you replace
> the whole vxlanhdr with vxlanhdr_gbp
> or split vxlanhdr into two 32-bit structs.
> then __packed hacks won't be needed.

The main reason why I merged it into vxlanhdr is for documentation
purposes and to avoid duplicating the generic VXLAN header for every
extension. The RCO and GPE extensions would need to duplicate this
over and over. It gets messy in particular when multiple extensions
can be used in combination (such as GBP and RCO) which then each
have their own conflicting header definitions. This way, it is clear
which extensions are compatible by just looking at the definition
of the structure.

That said, I'm not married to this idea.
