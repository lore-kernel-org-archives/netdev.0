From: Harald Welte <laforge@gnumonks.org>
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Thu, 1 Jun 2017 09:00:31 +0200
Message-ID: <20170601070031.mdycexartsu33fyd@nataraja>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
 <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
 <20170531122752.siaou43verg4epep@nataraja>
 <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
 <87a85si5f2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:39649 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdFAHPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 03:15:05 -0400
Content-Disposition: inline
In-Reply-To: <87a85si5f2.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Jun 01, 2017 at 01:32:49AM -0500, Eric W. Biederman wrote:

> If a network device does not implement rntl_link_ops it is returned to
> the initial network namespace.   Anything else will loose physical
> devices.

Thanks a lot for your statement.  This is a big relief, my line of
thinking thus is confirmed:  We shall not loose physical devices.

> Only for pure software based devices do we delete them.  Perhaps your
> sub interface implements rtnl_link_ops?  Either that or something is
> still holding a reference to your network namespace, which would prevent
> the network device from being returned.

My question is how to debug this further?  Monitoring
/proc/*/ns/net* showed that the ID of the namespace is gone after
terminating my processes in the namespace.  Short of adding printk() or
playing with kprobes: to the related kernel code, how can I track the
reference count or get an idea who might hold references?

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
