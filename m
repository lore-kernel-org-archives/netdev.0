From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: IPSEC IPV4 Tunnel Requires IPV6 WIth 2.6.25?
Date: Wed, 21 May 2008 21:01:05 +0900
Message-ID: <48340F01.6050104@miyazawa.org>
References: <1210882182.9684.27.camel@zeus.local>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_catalunya.miyazawa.org-13595-1211370655-0001-2"
Cc: netdev@vger.kernel.org
To: Alan Swanson <swanson@ukfsn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:59655 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760406AbYEUMG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 08:06:29 -0400
In-Reply-To: <1210882182.9684.27.camel@zeus.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_catalunya.miyazawa.org-13595-1211370655-0001-2
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

Hello,

This patch fixes the problem.
I though that someone (sorry I foget) sent the same patch
when netlink was fixed.

Alan Swanson wrote:
> Hi. Usual non-subscriber CC replies request please.
> 
> There is a problem with 2.6.25(.4) using IPSEC on ipv4. You seem to need
> to have ipv6 available otherwise a protocol not supported error is
> returned when trying to set a Security Association Database. I'm using
> setkey on a file but another user on the ipsec-tools-devel list reported
> the same issue using racoon.
> 
> ﻿http://marc.info/?l=ipsec-tools-devel&m=121015164014761&w=2
> 
> So with modules loaded you expect to work.
> 
> $ lsmod
>   Module                  Size  Used by
>   authenc                 5056  0 
>   ah4                     4672  0 
>   esp4                    5824  0 
>   aead                    5824  2 authenc,esp4
>   xfrm4_mode_tunnel       2176  20
> 
> A static file with tunnel configuration for laptop to desktop over open
> wireless not running WEP/WPA.
> 
> $ head -n 12 /etc/ipsec.conf
>   #!/usr/sbin/setkey -f
>   
>   flush;
>   spdflush;
>   
>   add 1.1.1.1 2.2.2.2 esp 0x500 -m tunnel
>   -E rijndael-cbc 0x...
>   -A hmac-sha1 0x...;
>   
>   add 2.2.2.2 1.1.1.1 esp 0x501 -m tunnel
>   -E rijndael-cbc 0x...
>   -A hmac-sha1 0x...;
> 
> You get protocol not supported error.
> 
> $ setkey -f /etc/ipsec.conf
>   ﻿The result of line 8: Protocol not supported.
>   The result of line 12: Protocol not supported.
> 
> But after modprobing ipv6 which automatically pulls
> in ﻿xfrm6_mode_tunnel, setkey starts working and I can communicate via
> IPSEC.
> 
> $ lsmod
>   Module                  Size  Used by
>   xfrm6_mode_tunnel       2048  4 
>   ipv6                  217444  10 xfrm6_mode_tunnel
>   authenc                 5056  4 
>   ah4                     4672  0 
>   esp4                    5824  4 
>   aead                    5824  2 authenc,esp4
>   xfrm4_mode_tunnel       2176  28
> 
> It really shouldn't need ipv6. Full kernel config, lsmod before and
> after modprobing ipv6 are available at below URL's.
> 
> http://www.swanson.ukfsn.org/ipsec/config
> http://www.swanson.ukfsn.org/ipsec/lsmod-post-modprobe-ipv6
> http://www.swanson.ukfsn.org/ipsec/lsmod-pre-modprobe-ipv6
> 

--
Kazunori Miyazawa

--=_catalunya.miyazawa.org-13595-1211370655-0001-2
Content-Type: text/plain; name="patch-fixing-af_key.txt"; charset=iso-8859-1
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="patch-fixing-af_key.txt"

c2lnbmVkLW9mZi1ieTogS2F6dW5vcmkgTUlZQVpBV0EgPGthenVub3JpQG1peWF6YXdhLm9y
Zz4KCmRpZmYgLS1naXQgYS9uZXQva2V5L2FmX2tleS5jIGIvbmV0L2tleS9hZl9rZXkuYwpp
bmRleCBlOWVmOWFmLi44MzVlMzA3IDEwMDY0NAotLS0gYS9uZXQva2V5L2FmX2tleS5jCisr
KyBiL25ldC9rZXkvYWZfa2V5LmMKQEAgLTEyMTksNyArMTIxOSw3IEBAIHN0YXRpYyBzdHJ1
Y3QgeGZybV9zdGF0ZSAqIHBma2V5X21zZzJ4ZnJtX3N0YXRlKHN0cnVjdCBzYWRiX21zZyAq
aGRyLAogICAgICAgICAgICAgICAgeC0+c2VsLnByZWZpeGxlbl9zID0gYWRkci0+c2FkYl9h
ZGRyZXNzX3ByZWZpeGxlbjsKICAgICAgICB9CiAKLSAgICAgICBpZiAoeC0+cHJvcHMubW9k
ZSA9PSBYRlJNX01PREVfVFJBTlNQT1JUKQorICAgICAgIGlmICgheC0+c2VsLm1vZGUpCiAg
ICAgICAgICAgICAgICB4LT5zZWwuZmFtaWx5ID0geC0+cHJvcHMuZmFtaWx5OwogCiAgICAg
ICAgaWYgKGV4dF9oZHJzW1NBREJfWF9FWFRfTkFUX1RfVFlQRS0xXSkgewoK
--=_catalunya.miyazawa.org-13595-1211370655-0001-2--
