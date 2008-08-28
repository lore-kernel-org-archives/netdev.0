From: "James King" <t.james.king@gmail.com>
Subject: Re: Questions about Linux kernel network programming
Date: Thu, 28 Aug 2008 11:12:35 -0700
Message-ID: <38bcb3ec0808281112v6b4be2eucbe77262e3ffe2a0@mail.gmail.com>
References: <3fedcc3b0808280733w1d7b24dgf95540d2078856f8@mail.gmail.com>
	 <3fedcc3b0808280748q4090c5e7n45c74c4fd3b42cca@mail.gmail.com>
	 <379e30200808280803j6a2a86bfya34ecc17127a1bbd@mail.gmail.com>
	 <3fedcc3b0808280919l65131584gf91d656f02e1d7ac@mail.gmail.com>
	 <20080828170206.GJ7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Thiago Lacerda" <thiagotbl@gmail.com>,
	"Tobias Koeck" <tobias.koeck@gmail.com>, netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:13912 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852AbYH1SMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 14:12:38 -0400
Received: by gv-out-0910.google.com with SMTP id e6so45217gvc.37
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 11:12:35 -0700 (PDT)
In-Reply-To: <20080828170206.GJ7908@solarflare.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 28, 2008 at 10:02 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> Thiago Lacerda wrote:
>> BTW, anyone knows the right way of get a tcp port number in human readable form?
>> I'm doing like this:
>>
>> struct tcphdr* tcp = tcp_hdr(my_sk_buff)
>>
>> unsigned short src_port = ntohs(tcp->source)
>>
>> And it isn't working, the numbers that I get are not right.
>
> Until the packet has gone through the network protocol handler (IP), the
> transport header pointer will not be set correctly and tcp_hdr() will return
> a pointer to the start of the packet.

Thanks for the explanation Ben, I was having the same problem with a
toy netfilter module hooked in prerouting a while ago and never
bothered to find out why.  Thiago, here's how I got it working:

struct tcphdr *th = NULL, _tcph;
struct iphdr *iph = ip_hdr(skb);
if (iph && iph->protocol == IPPROTO_TCP)
th = (struct tcphdr *)(skb->data + (iph->ihl * 4));

Alternatively, I think this will work too:
th = skb_header_pointer(skb, (iph->ihl * 4), sizeof(_tcph), &_tcph);


HTH
