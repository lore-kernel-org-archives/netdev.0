From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next 00/25] bonding: introduce new option API
Date: Tue, 21 Jan 2014 13:51:02 -0800
Message-ID: <E9519D4C-39CA-47D8-92E9-5CD6909571D8@cumulusnetworks.com>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com> <1390319983.26902.4.camel@dcbw.local>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:44886 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbaAUVvH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 16:51:07 -0500
In-Reply-To: <1390319983.26902.4.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 21, 2014, at 7:59 AM, Dan Williams <dcbw@redhat.com> wrote:

> On Tue, 2014-01-21 at 15:54 +0100, Nikolay Aleksandrov wrote:
>> Hi,
>> This patchset's goal is to introduce a new option API which should be used
>> to properly describe the bonding options with their mode dependcies and
>> requirements. With this patchset applied we get centralized option
>> manipulation, automatic RTNL acquire per option setting, automatic option
>> range checking, mode dependcy checking and other various flags which are
>> described in detail in patch 01's commit message and comments.
>> Also the parameter passing is changed to use a specialized structure which
>> is initialized to a value depending on the needs.
> 
> Currently userspace has to encode a lot of the same logic the kernel has
> for option validation, for example when creating a user interface for
> this stuff, you have to know that miimon and arp are incompatible, and
> that certain options are only relevant with certain bond modes, and it's
> a mess.  And this also sometimes changes when new kernel options or
> capabilities are added.

Note that if using the new netlink support for bonding via an updated ip link command, incompatible options will be caught and the command will fail.  For example, if you try to create a new bond and set both miimon and arp, the bond create will fail (and err msg logged).  Once the bond is created, again trying to set incompatible options with one command will fail in the same way.  If options are set one at a time on existing bond, then last set option takes precedence and may override earlier settings.

None of this is true if using sysfs.  So user-space tools should move to ip link (or netlink directly) rather than using sysfs for bond config.

> 
> So, is there any good way to describe the valid value ranges or
> capabilities for userspace?  One idea is to send a package of bond
> options to the kernel and see if they validate before actually applying
> them, though this only works when actually configuring the interface.
> An additional idea would be to somehow describe the available options
> (eg, value ranges for numeric values, list-of-strings for bond modes,
> etc) that the kernel supports before any bonds are even created (thus
> probably through netlink, not sysfs).
> 
> Thoughts?
