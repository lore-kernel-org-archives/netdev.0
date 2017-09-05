From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [oss-drivers] Re: [PATCH net] net: sched: don't use GFP_KERNEL
 under spin lock
Date: Tue, 5 Sep 2017 16:31:25 +0200
Message-ID: <20170905143125.GD7936@nanopsycho>
References: <20170905105442.30972-1-jakub.kicinski@netronome.com>
 <20170905115948.2fd38785@cakuba.netronome.com>
 <20170905125221.GA7936@nanopsycho>
 <20170905152551.748e4af2@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36480 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751647AbdIEOb2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 10:31:28 -0400
Received: by mail-wr0-f195.google.com with SMTP id 40so1808964wrv.3
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 07:31:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170905152551.748e4af2@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 05, 2017 at 04:25:51PM CEST, kubakici@wp.pl wrote:
>On Tue, 5 Sep 2017 14:52:21 +0200, Jiri Pirko wrote:
>> Tue, Sep 05, 2017 at 12:59:48PM CEST, kubakici@wp.pl wrote:
>> >Jiri, FWIW I also just noticed these, but they seem related to the
>> >earlier TC chain work?  
>> 
>> What do you do to trigger this?
>
>Sorry, I wasted a bit of time there because kmemleak takes surprisingly
>long to notice the memory leak...  In the end this is sufficient:
>
> modprobe nfp
> ifconfig p4p1 10.8.1.1/24 up
> tc qdisc add dev p4p1 handle ffff: ingress
> tc filter add dev p4p1 parent ffff: protocol 802.1Q flower vlan_id 600 \
>     action mirred egress redirect dev p4p1
> tc filter del dev p4p1 parent ffff:
> rmmod nfp

Will try. Thanks!
