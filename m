From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: xen-netback: make feature-rx-notify mandatory -- Breaks stubdoms
Date: Wed, 10 Dec 2014 14:12:19 +0000
Message-ID: <548854C3.7060008@citrix.com>
References: <54884DA8.7030003@nuclearfallout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "Xen-devel@lists.xen.org" <Xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John <jw@nuclearfallout.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:8386 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753874AbaLJOMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 09:12:22 -0500
In-Reply-To: <54884DA8.7030003@nuclearfallout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/14 13:42, John wrote:
> David,
> 
> This patch you put into 3.18.0 appears to break the latest version of
> stubdomains. I found this out today when I tried to update a machine to
> 3.18.0 and all of the domUs crashed on start with the dmesg output like
> this:

Cc'ing the lists and relevant netback maintainers.

I guess the stubdoms are using minios's netfront?  This is something I
forgot about when deciding if it was ok to make this feature mandatory.

The patch cannot be reverted as it's a prerequisite for a critical
(security) bug fix.  I am also unconvinced that the no-feature-rx-notify
support worked correctly anyway.

This can be resolved by:

- Fixing minios's netfront to support feature-rx-notify. This should be
easy but wouldn't help existing Xen deployments.

Or:

- Reimplement feature-rx-notify support.  I think the easiest way is to
queue packets on the guest Rx internal queue with a short expiry time.

> [   83.045785] device vif2.0 entered promiscuous mode
> [   83.059220] vif vif-2-0: 22 feature-rx-notify is mandatory
> [   83.060763] vif vif-2-0: 1 mapping in shared page 2047 from domain 2
> [   83.060861] vif vif-2-0: 1 mapping shared-frames 2047/2046 port tx 4
> rx 4
> 
> This is on the very latest patched version of 4.4.

David
