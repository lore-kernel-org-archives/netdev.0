From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Sun, 10 Jul 2016 19:38:42 +0300
Message-ID: <70150252-5989-63b7-9224-9dd4a572099a@gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-5-git-send-email-bblanco@plumgrid.com>
 <CAJ3xEMjjG2ZZe=qBsRaFuk-j8Akj38Uk6+Nw1xuZya=R7FOJ7Q@mail.gmail.com>
 <20160710154029.GA6657@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38883 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbcGJQir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 12:38:47 -0400
Received: by mail-wm0-f45.google.com with SMTP id o80so22874327wme.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 09:38:47 -0700 (PDT)
In-Reply-To: <20160710154029.GA6657@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>> +                       switch (act) {
>>> +                       case XDP_PASS:
>>> +                               break;
>>> +                       default:
>>> +                               bpf_warn_invalid_xdp_action(act);
>>> +                       case XDP_DROP:
>>> +                               goto next;
>>> +                       }
>>> +               }
>>
>> (probably a nit too, but wanted to make sure we don't miss something
>> here) is the default case preceding the DROP one in purpose? any
>> special reason to do that?
> This is intentional, and legal though unconventional C. Without this
> order, the later patches end up with a bit too much copy/paste for my
> liking, as in:
>
> case XDP_DROP:
>          if (mlx4_en_rx_recycle(ring, frags))
>                  goto consumed;
>          goto next;
> default:
>          bpf_warn_invalid_xdp_action(act);
>          if (mlx4_en_rx_recycle(ring, frags))
>                  goto consumed;
>          goto next;
The more critical issue here is the default action. All packets that get 
unknown/unsupported filter classification will be dropped.
I think the XDP_PASS is the better choice here as default action, there 
are good reasons why it should be, as Jesper already explained in 
replies to other patch in the series.

Regards,
Tariq
