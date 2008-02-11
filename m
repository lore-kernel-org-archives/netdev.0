From: "Jan Beulich" <jbeulich@novell.com>
Subject: Re: [patch 1/7] typhoon section fix
Date: Mon, 11 Feb 2008 08:22:32 +0000
Message-ID: <47B013D8.76E4.0078.0@novell.com>
References: <200802081120.m18BK6cL021623@imap1.linux-foundation.org>
 <1202479150.4349.0.camel@obelisk.thedillows.org>
 <20080208095233.722d7c47.akpm@linux-foundation.org>
 <1202494917.5298.3.camel@lap75545.ornl.gov>
 <20080208190340.GA31072@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <jeff@garzik.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Dillow" <dave@thedillows.org>, <netdev@vger.kernel.org>
To: "Sam Ravnborg" <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from public.id2-vpn.continvity.gns.novell.com ([195.33.99.129]:53235
	"EHLO public.id2-vpn.continvity.gns.novell.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752387AbYBKImM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 03:42:12 -0500
In-Reply-To: <20080208190340.GA31072@uranus.ravnborg.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>So do we have other options that to drop the constification and thus
>dropping the __devinitconst and the other __*const annotations - I think not :-(

As I had said already in another reply - I think the most reasonable thing
to do is to fold section name attribute *and* const into __*initconst
(while defining __*initconst to __*initdata on those targets not allowing
relocations in read-only sections, which should be done by a promptless
config option to avoid enumerating all the targets each time such a
conditional is needed somewhere). While that doesn't allow the 'const'
compile time checking on those problem targets, it is consistent for all
targets and provides the intended DEBUG_RODATA benefit where
possible. Additionally, the const compile time checking will then be more
tight on the presumable more frequently tested x86 targets, so the
chances of bad constructs slipping in should be reduced.

Jan

