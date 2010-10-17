From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: Documenting UNIX domain autobind
Date: Sun, 17 Oct 2010 14:28:58 +0900
Message-ID: <201010171428.DDC17187.FFFJSLtOOHOMQV@I-love.SAKURA.ne.jp>
References: <AANLkTimtTazMmDvQFgASsVGa=AYvPZqUaUmyg5p7VVY1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mzxreary@0pointer.de
To: mtk.manpages@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:59017 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092Ab0JQF3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Oct 2010 01:29:06 -0400
In-Reply-To: <AANLkTimtTazMmDvQFgASsVGa=AYvPZqUaUmyg5p7VVY1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Kerrisk wrote:
> I think this text correctly documents the technical details (but let
> me know if you see errors). What is lacking is an explanation of why
> this feature exists. Is someone able to explain where this feature is
> used and why?

What we can see is that unix_autobind() was added in Linux 2.1.15

  http://lxr.linux.no/linux-old+v2.1.15/net/unix/af_unix.c#L464
  addr->len = sprintf(addr->name->sun_path+1, "%08x", ordernum) + 1 + sizeof(short);

  49 * Differences from 2.0.0-11-... (ANK)
  50 *      Bug fixes and improvements.
  51 *              - client shutdown killed server socket.
  52 *              - removed all useless cli/sti pairs.
  53 *              - (suspicious!) not allow connect/send to connected not to us
  54 *                socket, return EPERM.
  55 *
  56 *      Semantic changes/extensions.
  57 *              - generic control message passing.
  58 *              - SCM_CREDENTIALS control message.
  59 *              - "Abstract" (not FS based) socket bindings.
  60 *                Abstract names are sequences of bytes (not zero terminated)
  61 *                started by 0, so that this name space does not intersect
  62 *                with BSD names.

and was changed to allow from 2^32 names to 2^20 names in Linux 2.3.15.

  http://lxr.linux.no/linux-old+v2.3.15/net/unix/af_unix.c#L514
  addr->len = sprintf(addr->name->sun_path+1, "%05x", ordernum) + 1 + sizeof(short);

I don't know the reason.

Regards.
