From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Wed, 02 Apr 2003 13:02:32 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030402.130232.78951283.yoshfuji@linux-ipv6.org>
References: <20030401.140727.73666851.davem@redhat.com>
	<20030402.122518.62753078.yoshfuji@linux-ipv6.org>
	<20030401.193429.64279267.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030401.193429.64279267.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030401.193429.64279267.davem@redhat.com> (at Tue, 01 Apr 2003 19:34:29 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

>    How about just removing 8 bytes from struct {ip,ipv6}_esp_hdr
>    like this?
>    
> Sure, but does anyone need the 8 bytes there?  I thought so, which is
> why I didn't think about your suggestion :-)

Let's define
  #define IPV6_ESP_MINDATA  8

and put "(sizeof(struct ip6_esp_hdr) + IPV6_ESP_MINDATA)" in such places.

Or, how about this?
  (offsetof(struct ip6_esp_hdr, enc_data) + datalen)
instead of
  ((sizeof(struct ip6_esp_hdr) - sizeof(esp->enc_data)) + datalen)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
