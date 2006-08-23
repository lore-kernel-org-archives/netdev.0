From: "Jari Sundell" <sundell.software@gmail.com>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 02:28:32 +0200
Message-ID: <b3f268590608221728r6cffd03i2f2dd12421b9f37@mail.gmail.com>
References: <11561555871530@2ka.mipt.ru> <1156230051.8055.27.camel@entropy>
	 <20060822072448.GA5126@2ka.mipt.ru> <1156234672.8055.51.camel@entropy>
	 <b3f268590608220957g43a16d6bmde8a542f8ad8710b@mail.gmail.com>
	 <20060822180135.GA30142@2ka.mipt.ru>
	 <b3f268590608221214l45bb6ad6meccfba99b89710a0@mail.gmail.com>
	 <20060822194706.GA3476@2ka.mipt.ru>
	 <b3f268590608221551q5e6a1057hd1474ee8b9811f10@mail.gmail.com>
	 <20060822231129.GA18296@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Nicholas Miell" <nmiell@comcast.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Ulrich Drepper" <drepper@redhat.com>,
	"Andrew Morton" <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	"Zach Brown" <zach.brown@oracle.com>,
	"Christoph Hellwig" <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.198]:38449 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751150AbWHWA2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 20:28:33 -0400
Received: by nz-out-0102.google.com with SMTP id 14so628580nzn
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2006 17:28:32 -0700 (PDT)
To: "Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060822231129.GA18296@ms2.inr.ac.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/06, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> Let me explain, as a person who did this mistake and deeply
> regrets about this.
>
> F.e. in this case you just cannot use kevents in 32bit application
> on x86_64, unless you add the whole translation layer inside kevent core.
> Even when you deal with plain syscall, translation is a big pain,
> but when you use mmapped buffer, it can be simply impossible.
>
> F.e. my mistake was "unsigned long" in struct tpacket_hdr in linux/if_packet.h.
> It makes use of mmapped packet socket essentially impossible by 32bit
> applications on 64bit archs.

There are system calls that take timespec, so I assume the magic is
already available for handling the timeout argument of kevent.
Although I'm not entirely sure about the kqueue timer interface, there
isn't any reason timespec would need to be written to the mmaped
buffer for the rest.

AFAICS, only struct ukevent is visible to the user, same would go for
kqueue's struct kevent.

Rakshasa
