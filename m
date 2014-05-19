From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 0/4] ISDN patches for net-next
Date: Mon, 19 May 2014 23:36:37 +0200
Message-ID: <537A7965.9070407@imap.cc>
References: <cover.1400448368.git.tilman@imap.cc> <20140518.213607.1866002359122979029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pebolle@tiscali.nl,
	isdn4linux@listserv.isdn4linux.de, isdn@linux-pingi.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:50849 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbaESVrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 17:47:20 -0400
In-Reply-To: <20140518.213607.1866002359122979029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

thanks for your reply. I understand your concerns but I don't agree
with them and hope I'll be able to convince you otherwise.

On 19.05.2014 03:36, you wrote:
> Since this has been broken for several years, you might be doing more
> harm than good by trying to change things back again.

You appear to assume that there is a currently working configuration
which might be broken by the patch series. That is not the case.
The (very few) remaining users of PPP over ISDN cope with the
current situation in one of these ways:

a) staying with a pre-3.0 kernel that still provides capifs

b) staying with (or reverting to) the deprecated ISDN4Linux subsystem

c) patching the kernel locally to fix the breakage

d) staying with an old udev version that can still rename device nodes

e) explicitly running commands like
    mv /dev/capi /dev/capi20
    mkdir /dev/capi
    ln -s /dev/capi0 /dev/capi/0
    ln -s /dev/capi1 /dev/capi/1
   on every boot, typically via /etc/boot.local or similar mechanisms.

f) giving up on Linux ISDN support and buying a separate router.

None of these will be broken by fixing the problem in the kernel:

- a), b) and f) won't notice anything unless they read the changelog
  and find they can at last use ISDN over CAPI with a current kernel
  again if they want to.

- c) will notice that the local kernel patch doesn't apply anymore
  and happily drop it.

- d) and e) may or may not notice that renaming the CAPI nodes fails
  because the nodes are already named correctly, but apart from a
  couple of log messages everything will work as before.

> Why not just have capiplugin able to search for and use the names
> generated now?

For one, capiplugin is a pretty old piece of software. The risk of
breaking it in the attempt to adapt it to the Kernel CAPI interface
change is far bigger than the risk associated with reverting that
change in the kernel. What's more, capiplugin is not the only
software affected. /dev/capi20 is the documented standard device
for CAPI 2.0 on Linux. Userspace relies on that. We would have to
adapt at least libcapi20 too, and possibly an unknown number of
other applications.

In sum, I'm convinced the proposed patch series is the minimally
invasive way of sorting out the current mess surrounding the
CAPI device files.

Regards,
Tilman
