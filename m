From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 net-next 4/4] sctp: implement sender-side procedures
 for Add Incoming/Outgoing Streams Request Parameter
Date: Tue, 24 Jan 2017 12:35:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB026CAD7@AcuExch.aculab.com>
References: <cover.1484845510.git.lucien.xin@gmail.com>
 <daa150a23548dda0a2fd513c622773f0ff9b2df3.1484845510.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB026B563@AcuExch.aculab.com>
 <20170123145347.GB31445@hmswarspite.think-freely.org>
 <20170123160234.GY3781@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:51011 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750721AbdAXMfs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 07:35:48 -0500
In-Reply-To: <20170123160234.GY3781@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 23 January 2017 16:03
...
> > > Does kcalloc() zero the entire area, or just the length you ask for?
> > > If the latter you need to zero the rest here.
> > Better still, just use krealloc.  You still need to zero out any space beyond
> > the old length, but it will make the code shorter, and avoid the need for
> > additional temporary variables.
> 
> Seems if we pass gfp | __GFP_ZERO to krealloc it will end up zeroing the
> slab for us before doing the memcpy.
> I didn't follow all paths but in slab_alloc_node it will end up calling:
>         if (unlikely(gfpflags & __GFP_ZERO) && object)
>                 memset(object, 0, s->object_size);
> So I would expect that other paths also do it.

You probably don't want krealloc() zeroing all of the new area.

	David
