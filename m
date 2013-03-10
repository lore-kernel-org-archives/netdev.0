From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: MBIM backwards compatibility and user vs kernel policy
Date: Sun, 10 Mar 2013 12:21:14 +0100
Message-ID: <87sj43cxg5.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@stericsson.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Greg Suarez <gsuarez@smithmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:50899 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751338Ab3CJLhr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 07:37:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I just realized that our current strategy for MBIM backwards
compatibility results in bad user experience by *forcing* the user to
cdc_mbim if it is enabled at build time. There are legitimate reasons f=
or
a user to select cdc_ncm instead of cdc_mbim at runtime, and at the
moment we prevent that.  The most obvious and important reason is that
the required MBIM userspace applications are not ready yet.  But even i=
n
a future where these are available, I believe we should leave the choic=
e
up to the user.

So our current build time based decision will not do.  But what will?
Is a cdc_ncm module param setting MBIM vs NCM priority OK?  We could
still make the default depend on whether cdc_mbim is built.  I don't
think there are any reasons to complicate this with a per-device
selection.  It is really a system wide setting depending on whether MBI=
M
is supported by the system.

What do you think?

This problem just came up as a result of a user failing to make Linux
v3.8 work on a Lenovo Thinkpad X230 with an Ericsson H5321gw Mobile
Broadband Device, while v3.7 appeared to work fine.  The H5321gw
firmware support NCM backwards compatibility, making it work fine with
cdc_ncm in v3.7. But in v3.8 we select the cdc_mbim alternate setting
instead, and ModemManager does not yet know how to handle that, making
it fail.

The user noticed the new cdc_mbim module and tried blacklisting it, as
one would find natural. But to no effect, as the problem is in the MBIM
compatibility check in cdc_ncm.  There appears to be no way to force th=
e
cdc_ncm driver in v3.8 to be used for this device if cdc_mbim is
selected at build time. Which of course is a distro choice and not
something most users will touch.

I believe we need to resolve this quickly, and I'll probably just cook =
up
a proposed module param patch unless someone comes up with something
better.

BTW, I am starting to hate the NCM backward compatibility. There were s=
o
many other ways this could have been solved. Changing class depending o=
n
the selected interface altsetting is ugly, IMHO.


Bj=C3=B8rn
