From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Thu, 21 Dec 2006 02:45:33 +0000
Message-ID: <20061221024533.GA1025@srcf.ucam.org>
References: <20061220042648.GA19814@srcf.ucam.org> <20061220144906.7863bcd3@dxpl.pdx.osdl.net> <20061221011209.GA32625@srcf.ucam.org> <200612202105.31093.flamingice@sourmilk.net> <20061221021832.GA723@srcf.ucam.org> <4589F39C.7010201@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([217.147.92.49]:48932 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161153AbWLUCpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 21:45:50 -0500
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <4589F39C.7010201@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 20, 2006 at 09:38:20PM -0500, Daniel Drake wrote:

> I don't think that supporting scanning when the interface is supposed to 
> be disabled is sensible. If you want to scan, you are simply sending and 
> receiving frames, it's no different from having the interface up and 
> sending/receiving data frames.

>From a usability point of view, it's helpful to power the card down as 
much as possible while it's not being actively used. However, it's also 
helpful to be able to provide a list of available wireless networks, 
though some degree of latency would be acceptable in that. These two 
desires are obviously not entirely compatible with one another, so it 
would be helpful if there was some means of providing an intermediate 
state.

> There are additional implementation problems: scanning requires 2 
> different ioctl calls: siwscan, then several giwscan. If you want the 
> driver to effectively temporarily bring the interface up when userspace 
> requests a scan but the interface was down, then how does the driver 
> know when to bring it down again?

Hm. Does the spec not set any upper bound on how long it might take for 
APs to respond? I'm afraid that my 802.11 knowledge is pretty slim. 
Picking a number out of thin air would be one answer, but clearly less 
than ideal. This may be a case of us not being able to satisfy everyone, 
and so just having to force the user to choose between low power or 
wireless scanning.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
