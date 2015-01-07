From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: RE: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Wed, 7 Jan 2015 09:54:30 -0800
Message-ID: <1b5a5a02b187fde4c2491ce757cb0045@mail.gmail.com>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com>
	 <1420552709.32369.50.camel@stressinduktion.org>		 <CAE4R7bCOnYL1bat39UivcyAG-S1hx-EJpwC_hWNv8prjZqV3fg@mail.gmail.com>
	 <1420574353.15181.19.camel@stressinduktion.org>	 <98433f41e1876041471cdb513ca53fe5@mail.gmail.com>
 <1420629792.26870.59.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	john fastabend <john.fastabend@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:43452 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbbAGSAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 13:00:03 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so8032982wiv.17
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 10:00:02 -0800 (PST)
In-Reply-To: <1420629792.26870.59.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>I could come up with several ways how to model hardware. Depending on that
>the integration with rules is easy or nearly impossible:
>
>1) it simply cannot deal with ip rules, so there is no way an ACL can
>influence the
>outcome of a routing table lookup - if the feature should be used, it has
>to use
>the slow-path in the kernel.

As Scott was saying, most hardware has table id's and the ability to
identify and prioritize that way.


>
>2) ACLs can influence which routing table will get queried - this sounds
>very much
>like the ip rule model and it seems not too hard to model that.

This clearly can be made to work .. the problem is really the space of
policy routing (i.e jump across VRF's incase of a lookup failure) when
combined with the space of ip rule flexibility.


>
>3) Routing implementations in the hardware have a single routing table and
>the
>leafs carry different actions with priorities: making this kind of model
>working
>with the ip rule concept will become very difficult and it might require
>lots of
>algorithmic code by every driver to adapt to a single API provided by
>Linux. It
>might be possible, if the hardware provides actions like backtrack and
>retrack and
>can keep state of priorities during walking the tree, I really doubt that.


In the short term .. this maybe a good way to go but with a simplication.
Some tables are offloaded and the rest at the full table level is in
software. Finally then you can put a "default route" in the hardware table
to punt to cpu and then keep the software model clever and the hardware
model fast ?

>
>Implementations of type 3) would look naturally to do in hardware (see
>different
>Cisco policy routing configurations or ipv6 subtree feature), so it seems
>it won't
>be possible to find a simple way to fuse rules and offloading in case of
>point 3).
>
>Rocker sounds a lot like model 2) and this seems possible and should be a
>matter
>of API design. It should merely be a matter of nicely model the data
>structures. ;)
>
>Also, @Scott: if you build drivers with l3 offloading as modules, don't you
>need to
>push the full routing tables to the hw once? Maybe we should think about
>the
>drivers pulling routing information from the kernel, the kernel only
>notifying
>something changed?
>
>Bye,
>Hannes
>
