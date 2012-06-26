From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: HSR: How to set IF_OPER_LOWERLAYERDOWN?
Date: Tue, 26 Jun 2012 15:33:24 -0700
Message-ID: <20120626153324.455c6081@nehalam.linuxnetplumber.net>
References: <4FEA37A0.309@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Javier Boticario <jboticario@gmail.com>,
	Bruno Ferreira <balferreira@googlemail.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52820 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751960Ab2FZWdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 18:33:33 -0400
In-Reply-To: <4FEA37A0.309@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jun 2012 22:28:51 +0000
Arvid Brodin <Arvid.Brodin@xdin.com> wrote:

> Hi,
> 
> According to Documentation/networking/operstates.txt a network interface have an
> operational state and an administrative state.
> 
> If I understand things correctly the administrative state is the desired state set by
> userspace, and the operational state is the actual state which depends on things like the
> administrative state, whether a carrier is present, or (for virtual interfaces lite VLAN)
> whether the lower interface is available.
> 
> 
> In the driver I'm writing (for the "HSR" redundancy protocol) a hsr (virtual) interface is
> useable as long as any of its (physical) slaves are useable. I.e. the operstate of a hsr
> device might be set like this:
> 
> void hsr_set_operstate()
> {
> 	if (!is_admin_up(hsr_dev)) /* Check IFF_UP */ {
> 		set_operstate(hsr_dev, IF_OPER_DOWN);
> 		return;
> 	}
> 
> 	if (is_operstate_up(slave1) || is_operstate_up(slave2)) /* Check IF_OPER_UP */
> 		set_operstate(hsr_dev, IF_OPER_UP);
> 	else
> 		set_operstate(hsr_dev, IF_OPER_LOWERLAYERDOWN);
> }


According to 802.1X example in documentation to set it down you need to set IF_OPER_DORMANT
not IF_OPER_LOWERLAYERDOWN.  Probably a kernel bug in there somwhere.
