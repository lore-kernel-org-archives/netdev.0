From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Wed, 02 Jul 2003 09:18:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030702.091825.72842784.yoshfuji@linux-ipv6.org>
References: <20030627.144752.78715628.davem@redhat.com>
	<20030628.130602.63704890.yoshfuji@linux-ipv6.org>
	<3F008771.5030206@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com
In-Reply-To: <3F008771.5030206@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <3F008771.5030206@us.ibm.com> (at Mon, 30 Jun 2003 11:54:41 -0700), Krishna Kumar <krkumar@us.ibm.com> says:

> Well, there are two reason that I can see to not do so (ADDRCONF flag is already
> fixed in earlier patch) :
:

You do not explain why we (or kernel) NEED(s) this.
It is not so important how SMALL it is
though it may cause problems how LARGE it is.


> About your point about the managed flag, I think it is a per interface flag
> that gets returned when a request for getting flags on that interface is made.
> That's why I have made it per interface as part of a GETLNKFLAGS operation.
> I don't understand why you think it is NEWLINK thing (not sure what you mean by
> that), since it is a flag information on your existing device that a RA is
> advertising. I want to get this information not on receipt of an RA, but when
> a request is made.

This is design issue; how we should provide L3 per-interface 
information to userspace; eg. in_device and/or inet6_dev things 
including per-interface statistics.

Since I think it is not appropriate to provide per-interface 
statistics via RTM_xxxROUTE, so I don't agree to provide 
the RA infomation (i.e. Manage/Otherconf Flags) via 
RTM_xxxROUTE.

Options:
 - use RTM_xxxLINK for L3 operation
 - introduce RTM_xxxIFACE for L3 per-interface operations

I really want to hear from other maintainers here...
David? Alexey?


Well, on moving forward; you can split your patch up to 3 things:
  1. fix routing flags
  2. provide Managed/Otherconf flags API
 (3. provide the prefix list API (if it IS required))

I'm not against the first item.
We need to discuss on the design related to the 2nd item.
I don't think that we really need 3rd item.


Thank you.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
