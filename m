From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Wed, 02 Apr 2003 12:25:18 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030402.122518.62753078.yoshfuji@linux-ipv6.org>
References: <1049234673.5116.11.camel@tomlt2.tomloffice.austin.ibm.com>
	<20030401.140727.73666851.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030401.140727.73666851.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030401.140727.73666851.davem@redhat.com> (at Tue, 01 Apr 2003 14:07:27 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

>    From: Tom Lendacky <toml@us.ibm.com>
>    Date: 01 Apr 2003 16:04:32 -0600
>    
>    Please review and let me know if any changes are required.
> 
> Ok, now that I look at this I realize my suggestions from the other
> day were wrong.
> 
> These expressions are huge, it's almost less readable.  Let's compact
> this, by creating a struct named {ip,ipv6}_esp_header_no_enc_data.

How about just removing 8 bytes from struct {ip,ipv6}_esp_hdr
like this?

struct ipv6_auth_hdr {
	__u8  nexthdr;
	__u8  hdrlen;
	__u16 reserved;
	__u32 spi;
	__u32 seq_no;
	__u8  auth_data[0];
} __attribute__ ((aligned (8)));

struct ipv6_esp_hdr {
	__u32 spi;
	__u32 seq_no;
	__u8  enc_data[0];
} __attribute__ ((aligned (8)));

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
