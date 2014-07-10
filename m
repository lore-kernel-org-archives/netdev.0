From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Thu, 10 Jul 2014 11:36:22 -0400
Message-ID: <CA+FuTSd9iJqfntCXNMSiX0YKKGvLvKDJ9XBnh2m3sfRNJDLvdw@mail.gmail.com>
References: <1404416380-3545-2-git-send-email-willemb@google.com>
 <20140705201851.GE3869@localhost.localdomain> <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com>
 <20140707184700.GA1610@localhost.localdomain> <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com>
 <53BAF8AC.6010907@cavium.com> <20140707201156.GA10265@localhost.localdomain>
 <53BB0B2A.3060708@cavium.com> <20140708060441.GB3977@localhost.localdomain>
 <53BBA0F6.3090003@caviumnetworks.com> <20140708094118.GB6249@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chad Reese <kreese@caviumnetworks.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Daney <david.daney@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:41685 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbaGJPgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 11:36:53 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so7728414qga.23
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 08:36:53 -0700 (PDT)
In-Reply-To: <20140708094118.GB6249@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So, the question becomes, will removing the sys time stamp from the
> octeon driver spoil your application?

Chad? If it cannot be removed easily, I will prepare the temporary
documentation patch to mark the field as deprecated.

On the topic of this original patch: I'll remove SCM_TSTAMP_HWSYS
and will simplify ee_info to only hold a type. No need for an explicit
index field if we simply assume that the ts[] index is always 0, except
for SCM_TSTAMP_HW, which is 2. We can even copy that one into
both fields 0 and 2 and consider the latter as a legacy workaround.
