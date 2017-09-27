From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v9] openvswitch: enable NSH support
Date: Wed, 27 Sep 2017 09:39:09 +0800
Message-ID: <20170927013908.GA33716@localhost.localdomain>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
 <20170925201439.08460295@griffin>
 <20170926045538.GA5896@localhost.localdomain>
 <20170926124914.60101ca1@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>, jan.scheurich@ericsson.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58818 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033022AbdI0BnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 21:43:25 -0400
Content-Disposition: inline
In-Reply-To: <20170926124914.60101ca1@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 06:49:14PM +0800, Jiri Benc wrote:
> On Tue, 26 Sep 2017 12:55:39 +0800, Yang, Yi wrote:
> > After push_nsh, the packet won't be recirculated to flow pipeline, so
> > key->eth.type must be set explicitly here, but for pop_nsh, the packet
> > will be recirculated to flow pipeline, it will be reparsed, so
> > key->eth.type will be set in packet parse function, we needn't handle it
> > in pop_nsh.
> 
> This seems to be a very different approach than what we currently have.
> Looking at the code, the requirement after "destructive" actions such
> as pushing or popping headers is to recirculate.

This is optimization proposed by Jan Scheurich, recurculating after push_nsh
will impact on performance, recurculating after pop_nsh is unavoidable, So
also cc jan.scheurich@ericsson.com.

Actucally all the keys before push_nsh are still there after push_nsh,
push_nsh has updated all the nsh keys, so recirculating remains avoidable.

> 
> Setting key->eth.type to satisfy conditions in the output path without
> updating the rest of the key looks very hacky and fragile to me. There
> might be other conditions and dependencies that are not obvious.
> I don't think the code was written with such code path in mind.
> 
> I'd like to hear what Pravin thinks about this.
> 
>  Jiri
