From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Wed, 1 Mar 2017 11:22:28 +0100
Message-ID: <20170301112228.713bd4d5@griffin>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
        <20170225173927.GA2479@nanopsycho>
        <1488054142.3856.15.camel@post.cz>
        <20170226075633.GA1788@nanopsycho>
        <1488117614.1903.2.camel@post.cz>
        <20170226144610.GB2071@nanopsycho.orion>
        <20170227173825.39e00c61@griffin>
        <1488312457.2131.2.camel@post.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: Zaboj Campula <zaboj.campula@post.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60322 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751499AbdCAKbx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Mar 2017 05:31:53 -0500
In-Reply-To: <1488312457.2131.2.camel@post.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Feb 2017 20:07:37 +0000, Zaboj Campula wrote:
> Well it is impossible to draw a simple tree showing the configuration
> exactly with all details. May be it is too ambitious to draw a tree
> at all.

I tried that and failed. I didn't want to have something that would
work only "somehow" as that would create confusion instead of helping.
See the example below.

> But neither directory structure is a tree (when consider links)
> and there are a plenty of tools showing directory tree.

Directory structure *is* a tree. Symlinks are a special case, for the
purpose of displaying the tree they're just files. Hardlinks can be
ignored when displaying a tree (because there are no hardlinks to
directories). We don't have any of that.

Consider the very simple case of an interface with two vlan interfaces
and both of them in a bridge.

         vlan0
      /        \
eth0             br0
      \        /
         vlan1

You can't represent this in a tree view. And this is just a very simple
example, in reality it tends to be much more complex.

 Jiri
