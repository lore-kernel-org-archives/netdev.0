From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ss: Show more info (ring,fanout) for packet
 socks
Date: Thu, 14 May 2015 14:09:00 +0300
Message-ID: <20150514110900.GA28582@angus-think.wlc.globallogic.com>
References: <1431509966-5054-1-git-send-email-vadim4j@gmail.com>
 <CA+FuTSeM_FQBRToXCBix9ns3_07ivfqxYHB4nGHcSqqp31fX5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33268 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbENLJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 07:09:42 -0400
Received: by wicmx19 with SMTP id mx19so12505764wic.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 04:09:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+FuTSeM_FQBRToXCBix9ns3_07ivfqxYHB4nGHcSqqp31fX5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 05:10:38PM -0400, Willem de Bruijn wrote:
> > +               }
> > +               if (has_fanout) {
> > +                       uint16_t type = (fanout >> 16) & 0xffff;
> 
> type can be modified by flags in the upper 8 bits. Better
> mask those out and report them separately.
Kernel puts only id & type in diag message, flags are stored in separated
member of 'struct packet_sock'.

> 
> > +
> > +                       printf("\n\tfanout(");
> > +                       printf("id:%d,", fanout & 0xff);
> > +                       printf("type:0x%x", type);
> > +                       if (type == 0)
> > +                               printf("(hash)");
> > +                       else if (type == 1)
> > +                               printf("(lb)");
> > +                       else if (type == 2)
> > +                               printf("(cpu)");
> > +                       else if (type == 3)
> > +                               printf("(rollover)");
> > +                       else if (type == 4)
> > +                               printf("(random)");
> > +                       else if (type == 5)
> > +                               printf("(qm)");
