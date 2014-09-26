From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Fri, 26 Sep 2014 06:38:17 -0700
Message-ID: <1411738697.16953.124.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com>
	 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
	 <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411611140.16953.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411688409.16953.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1749E380@AcuExch.aculab.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1749E538@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:48319 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821AbaIZNiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 09:38:19 -0400
Received: by mail-pd0-f179.google.com with SMTP id ft15so12926163pdb.38
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 06:38:19 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1749E538@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-26 at 13:16 +0000, David Laight wrote:

> OTOH it looks as though there is a big hit if you read then write
> a non-present cache line.

Well, this is exactly what it is about. Welcome to the club.

This is a well known problem.

Look at following old commit :

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=3f9d35b9514da6757ca98831372518f9eeb71b33
