From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Thu, 27 Nov 2014 19:34:46 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411271932510.1548@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-842611585-1417113292=:1548"
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org, Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org,
	youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org
To: Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-842611585-1417113292=:1548
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

What I suspect, is that all this mess started when Huawei introduce new 
firmware releases that changed something in the IPV6 support.
Bjorn - do you remember when a guy called Thomas reported us a problem about an 
LTE huawei modem that wasn't working with huawei_cdc_ncm?
And you then discovered the problem was originated from some changes in the 
ordering of cdc_ncm actions; what happened then?
Did Thomas get his modem back to working state?
Sorry Thomas - you wilol read this message but I don't remember your surname, 
and might get confused with other people called Thomas.


On Thu, 27 Nov 2014, Alex Strizhevsky wrote:

==Date: Thu, 27 Nov 2014 13:36:37
==From: Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==To: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>, ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org,
==    Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org
==Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
==    linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
==    Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org
==Subject: Re: Is this 32-bit NCM?
==
==Adding my colleagues - Eli, Kevin & Midge.
==
==Any ideas are welcome ;)
==
==
==On Thu, Nov 27, 2014 at 12:03 PM, Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
==      Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
==
==      > Ok - we can arrive to some ocnclusions regarding the E3272.
==      > First of all - the modem seems buggy enough to not be able to
==      handle requests
==      > for different formats. You need to unplug and re-plug it, but
==      this is onlyan
==      > impression and is reasonable.
==      >
==      > Then - the modem will accept to ndisdup the connection with
==      > at^ndisdup=1,1,"internet"
==      > but - if we use huawei_cdc_ncm + cdc_ncm we have no flow
==      handling messages and
==      > the modem stops here.
==      > If we use the cdc_ncm 32-bit driver (modified) we get lotfs of
==      > ^dsflorpt
==      > that's how it should be.
==      > So I think we can say that something is changing.
==      > Then there's the alignment problem you mentioned in your
==      previous reply. And
==      > this is hard to solve.
==      > could you try to help me understand where the problem is?
==      > I feel like we are very close to the solution but something
==      isn't working.
==      > Or might be just try to change the 16 bit driver?
==
==If you use a recent version of the driver as a basis, then you get the
==CDC NCM NTB parameters in sysfs (if not, then you need to enable
==debugging and look in the log for these values).  For example:
==
==bjorn@nemi:~$ grep . /sys/class/net/wwan0/cdc_ncm/*
==/sys/class/net/wwan0/cdc_ncm/bmNtbFormatsSupported:0x0001
==/sys/class/net/wwan0/cdc_ncm/dwNtbInMaxSize:15360
==/sys/class/net/wwan0/cdc_ncm/dwNtbOutMaxSize:15360
==/sys/class/net/wwan0/cdc_ncm/min_tx_pkt:13824
==/sys/class/net/wwan0/cdc_ncm/rx_max:15360
==/sys/class/net/wwan0/cdc_ncm/tx_max:15360
==/sys/class/net/wwan0/cdc_ncm/tx_timer_usecs:400
==/sys/class/net/wwan0/cdc_ncm/wNdpInAlignment:4
==/sys/class/net/wwan0/cdc_ncm/wNdpInDivisor:1
==/sys/class/net/wwan0/cdc_ncm/wNdpInPayloadRemainder:0
==/sys/class/net/wwan0/cdc_ncm/wNdpOutAlignment:4
==/sys/class/net/wwan0/cdc_ncm/wNdpOutDivisor:32
==/sys/class/net/wwan0/cdc_ncm/wNdpOutPayloadRemainder:0
==/sys/class/net/wwan0/cdc_ncm/wNtbOutMaxDatagrams:32
==
==
==The possible problem I am thinking of is proper handling of the
==wNdp*PayloadRemainder values. See section 3.3.4 "NCM Ethernet Frame
==Alignment" in the spec.  Which is confusing as hell, but if I
==understand
==it correctly then we are supposed to align the start of the IP packets
==(the "payload", _not_ the ethernet frame) to a whole wNdp*Divisor
==number
==as long as the wNdp*PayloadRemainder is 0.
==
==
==Bjørn
==
==
==
==
--8323328-842611585-1417113292=:1548--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
