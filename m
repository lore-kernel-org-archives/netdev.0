From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH iproute2] ss: Show more info (ring,fanout) for packet socks
Date: Thu, 14 May 2015 15:54:41 -0400
Message-ID: <CA+FuTSditeDHFKD-NLUJsZ=Cgyzca3RZysecRAx=whzpg+E6cg@mail.gmail.com>
References: <1431509966-5054-1-git-send-email-vadim4j@gmail.com>
 <CA+FuTSeM_FQBRToXCBix9ns3_07ivfqxYHB4nGHcSqqp31fX5A@mail.gmail.com> <20150514110900.GA28582@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36795 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161038AbbENTzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 15:55:12 -0400
Received: by obbkp3 with SMTP id kp3so61050353obb.3
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 12:55:12 -0700 (PDT)
In-Reply-To: <20150514110900.GA28582@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 7:09 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> On Wed, May 13, 2015 at 05:10:38PM -0400, Willem de Bruijn wrote:
>> > +               }
>> > +               if (has_fanout) {
>> > +                       uint16_t type = (fanout >> 16) & 0xffff;
>>
>> type can be modified by flags in the upper 8 bits. Better
>> mask those out and report them separately.
> Kernel puts only id & type in diag message, flags are stored in separated
> member of 'struct packet_sock'.

I don't mean pdi_flags, but

  PACKET_FANOUT_FLAG_ROLLOVER
  PACKET_FANOUT_FLAG_DEFRAG

which are passed as part of this u32 by the process during setsockopt
PACKET_FANOUT.

>
>>
>> > +
>> > +                       printf("\n\tfanout(");
>> > +                       printf("id:%d,", fanout & 0xff);
>> > +                       printf("type:0x%x", type);
>> > +                       if (type == 0)
>> > +                               printf("(hash)");
>> > +                       else if (type == 1)
>> > +                               printf("(lb)");
>> > +                       else if (type == 2)
>> > +                               printf("(cpu)");
>> > +                       else if (type == 3)
>> > +                               printf("(rollover)");
>> > +                       else if (type == 4)
>> > +                               printf("(random)");
>> > +                       else if (type == 5)
>> > +                               printf("(qm)");
