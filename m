From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [oss-drivers] Re: [PATCH net] net: sched: don't use GFP_KERNEL
 under spin lock
Date: Tue, 5 Sep 2017 15:25:51 +0100
Message-ID: <20170905152551.748e4af2@cakuba.netronome.com>
References: <20170905105442.30972-1-jakub.kicinski@netronome.com>
        <20170905115948.2fd38785@cakuba.netronome.com>
        <20170905125221.GA7936@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:11326 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751846AbdIEOZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 10:25:56 -0400
In-Reply-To: <20170905125221.GA7936@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Sep 2017 14:52:21 +0200, Jiri Pirko wrote:
> Tue, Sep 05, 2017 at 12:59:48PM CEST, kubakici@wp.pl wrote:
> >Jiri, FWIW I also just noticed these, but they seem related to the
> >earlier TC chain work?  
> 
> What do you do to trigger this?

Sorry, I wasted a bit of time there because kmemleak takes surprisingly
long to notice the memory leak...  In the end this is sufficient:

 modprobe nfp
 ifconfig p4p1 10.8.1.1/24 up
 tc qdisc add dev p4p1 handle ffff: ingress
 tc filter add dev p4p1 parent ffff: protocol 802.1Q flower vlan_id 600 \
     action mirred egress redirect dev p4p1
 tc filter del dev p4p1 parent ffff:
 rmmod nfp
