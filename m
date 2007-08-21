From: "Fortier,Vincent [Montreal]" <Vincent.Fortier1@EC.GC.CA>
Subject: 2.6.22 dev_base changes info request
Date: Tue, 21 Aug 2007 10:22:49 -0400
Message-ID: <F1D642E5A91BC94D9504EC83AE19E6B0128B25@ecqcmtlmail3.quebec.int.ec.gc.ca>
References: <20070820203209.GB4181@linux-7mw0.qlogic.org> <11877040854129-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwstl1-1.wul.qc.ec.gc.ca ([205.211.132.24]:18927 "EHLO
	ecqcmtlbh.quebec.int.ec.gc.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753695AbXHUO2l convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 10:28:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <11877040854129-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi all,

Sadly I have to use the Apani/Nortel cvc contivity linux client.  The
latest version (3.5) stopped being compatible with the latest stable
2.6.22 kernel.

Since there will most probably not be a new release from apani until
year 2013 we have hack the linux_wrapper.c file to try to keep the
module compatible.

Based on the horrors that showed up while compiling against the 2.6.22
kernel (see below), I was wondering if somebody would be kind enough to
give hints/examples/doc-url/etc on how to convert dev_base calls so we
ca find a proper way to make the linux_wrapper.c file compatible with
the latest stable kernel.

Here are the make against 2.6.22 kernel horrors:
  CC [M]
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.o
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'init_misc':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:310: error: 'dev_base' undeclared (first use in this function)
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:310: error: (Each undeclared identifier is reported only once
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:310: error: for each function it appears in.)
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'nl_ip_rcv':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:434: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'dev_next':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:497: error: 'net_device_t' has no member named 'next'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'nl_skb_dup':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:549: error: 'struct sk_buff' has no member named 'h'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:549: error: 'struct sk_buff' has no member named 'h'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:550: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:550: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:551: error: 'struct sk_buff' has no member named 'mac'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:551: error: 'struct sk_buff' has no member named 'mac'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'nl_skb_hdr_copy':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:576: error: 'struct sk_buff' has no member named 'h'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:576: error: 'struct sk_buff' has no member named 'h'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:577: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:577: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:578: error: 'struct sk_buff' has no member named 'mac'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:578: error: 'struct sk_buff' has no member named 'mac'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'nl_skb_iph':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:595: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'nl_send_skb':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:616: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:619: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'nl_data_len':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:658: error: invalid operands to binary -
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c: In function 'do_checksum_offload':
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:752: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:768: error: 'struct sk_buff' has no member named 'nh'
/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wrap
per.c:772: error: 'struct sk_buff' has no member named 'nh'
make[3]: ***
[/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6/linux_wra
pper.o] Error 1
make[2]: ***
[_module_/usr/src/Nortel/Apani_VPN_v3.5/cvc_linux-rh-gcc3-3.5/src/k2.6]
Error 2

Note, here is the line 310:
void init_misc(void)
{

        nl_dev_base = dev_base;
}


Help very much appreciated.

- vin
