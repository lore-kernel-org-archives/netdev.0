From: Harald Welte <laforge@gnumonks.org>
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Thu, 1 Jun 2017 01:13:52 +0200
Message-ID: <20170531231352.hdyvjujaioy3gbze@nataraja>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
 <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
 <20170531122752.siaou43verg4epep@nataraja>
 <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
 <20170531181108.3kv5xqszwv5ub7cy@nataraja>
 <CAM_iQpWicK0XySQ+L+DtVi2e2hUZx7w9CL0hC-kOaQsdbpXKtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:36689 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdEaXPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 19:15:05 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpWicK0XySQ+L+DtVi2e2hUZx7w9CL0hC-kOaQsdbpXKtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Wed, May 31, 2017 at 03:40:33PM -0700, Cong Wang wrote:
> But you have other choices than using the physical interface
> directly in non-root ns, for example, creating a virtual pair and
> connect it with the physical one with a bridge. There are various
> ways to achieve this.

Yes, but then those "workarounds" expose the given physical device to
the root namespace, which is exactly what I try to avoid here.  The
interface has no purpose outside of the specific target namespace, and
under no circumstances should the various applications on a normal Linux
system (whether it's network manager or whatever else) start to use the
device.  The same also applies to the kernel itself.  It is not
desirable to have the "root netns" start to do things like ipv6
stateless autoconfiguration, etc.

I of course know that all of those things can be individually disabled.

I just think having a physical netdev inside "single application"
namespaces is more complicated than it could be.

However, I have sufficiently made my argument clear, and I understand
that you don't share my concern.  This is perfectly fine. We agree to
disagree :)

I simply have to find the least intrusive work-around to my liking for
the intentional but so far undocumented behavior of netdevices vanishing
into thin air.  I'll manage.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
