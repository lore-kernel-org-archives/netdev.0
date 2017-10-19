From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v12] openvswitch: enable NSH support
Date: Fri, 20 Oct 2017 05:53:12 +0800
Message-ID: <20171019215312.GA91385@cran64.bj.intel.com>
References: <1508162009-30359-1-git-send-email-yi.y.yang@intel.com>
 <20171018231955.058ec5c8@griffin>
 <20171019114052.GA83037@cran64.bj.intel.com>
 <20171019144347.421351db@griffin>
 <20171019131215.GA84551@cran64.bj.intel.com>
 <20171019154118.16d906e0@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "pshelar@ovn.org" <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12721 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751856AbdJSWIt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 18:08:49 -0400
Content-Disposition: inline
In-Reply-To: <20171019154118.16d906e0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 03:41:18PM +0200, Jiri Benc wrote:
> On Thu, 19 Oct 2017 21:12:15 +0800, Yang, Yi wrote:
> > flow_key in set_nsh is got from netlink message which is set by
> > commit_nsh in user space, here is code.
> 
> Isn't this the 'key' local variable that you're talking about, while I'm
> referring to the 'flow_key' parameter?

Oh, my mistake, but it is possible not to polulate nsh key in flow_key
for push_nsh then set, as Jan and I explained before, we don't
recirculate the packet after push_nsh for performance, so parse function
isn't called for NSH header, mdtype can't be gotten from flow_key yet.
Only one case is true, i.e. an ingress NSH packet is parsed then set by 
changing si and ttl.

For push_nsh, my typical use scinario is push_nsh then set then output
to vxlangpe port.

> 
>  Jiri
