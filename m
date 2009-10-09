From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Real networking namespace
Date: Fri, 9 Oct 2009 08:38:07 -0700
Message-ID: <20091009083807.16e55b08@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, netdev@vger.kernel.org
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59233 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760858AbZJIPit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2009 11:38:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing networking namespace model is unattractive for what I want,
has anyone investigated better alternatives?

I would like to be able to allow access to a network interface and associated objects
(routing tables etc), to be controlled by Mandatory Access Control API's.
I.e grant access to eth0 and to only certain processes.  Some the issues
with the existing models are:
  * eth0 and associated objects don't really exist in filesystem so
    not subject to LSM style control (SeLinux/SMACK/TOMOYO)
  * network namespaces do not allow object to exist in multiple namespaces.
    The current model is more restrictive than chroot jails. At least with
    chroot, put filesystem objects in multiple jails.

Since one of the first rules of security is "don't reinvent", surely
others have dealt with this issue. Any good ideas?
