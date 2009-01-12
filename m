From: Patrick McHardy <kaber@trash.net>
Subject: Re: XFRM structures binary compability
Date: Mon, 12 Jan 2009 15:41:59 +0100
Message-ID: <496B56B7.3080703@trash.net>
References: <200901091324.3936@centrum.cz> <200901091325.24572@centrum.cz> <200901091326.18260@centrum.cz> <200901091327.25342@centrum.cz> <200901091328.6816@centrum.cz> <200901091329.27638@centrum.cz> <200901091330.17816@centrum.cz> <200901091331.18342@centrum.cz> <200901121454.21748@centrum.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: klimes@centrum.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33200 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbZALOmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 09:42:03 -0500
In-Reply-To: <200901121454.21748@centrum.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

klimes@centrum.cz wrote:
> Hello,
> 
> I face a problem due to binary incompatibility of XFRM structures.
> 
> I use XFRM interface to create IPsec SAs. My user application is compiled as 32bit binary.
> It works properly when running against 32bit kernel. However when I've run it on 64bit kernel, netlink returns an error (EINVAL).
> I use Fedora for both 32 and 64-bit environment.
> 
> I'm aware that it is due to incompatibility (different alignment and padding) of XFRM structures passed between user space and kernel
> (defined here for user space: /usr/include/linux/xfrm.h)
> My question is: shall not the structures be designed to be the same in 32 and 64bit environment?
> I think a padding should be added to meet the more strict alignment rules (i.e. 64bit environment).
> 
> I used pahole tool (available in dwarves package) to display structure alignment (see attachment).
> pahole_32.txt - structures from 32bit binary
> pahole_64.txt - structures from 64bit binary
> 
> What causes my trouble is "xfrm_usersa_info" which is padded with 7 bytes at the end in 64-bit,
> so that the whole structure is 224 bytes in 64bit application against 220 bytes in 32bit (just 3-byte padding).
> An explicit 7-byte padding in the structure would cure the case, IMHO.

That would break on 32 bit because userspace binaries compiled
with the old layout would send "short" messages. I'd suggest
to explicitly use the smaller value for the xfrm_msg_min checks
(i.e. replace sizeof by numerical constant).
