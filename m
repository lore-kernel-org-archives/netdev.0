From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] netdevice.7: document SIOCGIFCONF case ifc_req==NULL
Date: Thu, 16 Jan 2014 17:23:58 +1300
Message-ID: <52D75EDE.4020404@gmail.com>
References: <20140109233018.886FA140064@xenon.ts.pxnet.com> <52D03351.20501@gmail.com> <52D04B8B.3040306@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
	netdev@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:47130 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaAQEqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 23:46:12 -0500
In-Reply-To: <52D04B8B.3040306@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2014 08:35 AM, Tilman Schmidt wrote:
> Hello Michael,
> 
> Am 10.01.2014 18:52, schrieb Michael Kerrisk (man-pages):
>> On 01/10/2014 12:30 PM, Tilman Schmidt wrote:
>>> Add the missing description of the possibility to call SIOCGIFCONF
>>> with ifc_req==NULL to determine the needed buffer size, as described
>>> in http://lkml.indiana.edu/hypermail/linux/kernel/0110.1/0506.html
>>> and verified against source files net/core/dev_ioctl.c and
>>> net/ipv4/devinet.c in the current kernel git tree.
> [...]>
>> Thanks for the patch. I'm trying to verify this from the code, but 
>> am having some trouble finding the relevant pieces. Could you point
>> me more specifically at the points in the kernel source where this
>> case is handled?
> 
> Gladly.
> 
> Function dev_ifconf() [net/core/dev_ioctl.c line 67ff.] is the main
> handler for SIOCGIFCONF. It calls the registered protocol specific
> handlers via the table gifconf_list[]. The current kernel has only
> one such handler, inet_gifconf() [net/ipv4/devinet.c line 1115ff.]
> 
> If ifc.ifc_buf is NULL, dev_ifconf() calls the protocol specific
> handlers with NULL as second argument. [net/core/dev_ioctl.c line 96]
> 
> If inet_gifconf() is called with NULL as second argument it just
> adds up the data sizes, skipping the size check and data transfer.
> [net/ipv4/devinet.c line 1127f.]

Thanks. Patch applied.

Cheers,

Michael




-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
