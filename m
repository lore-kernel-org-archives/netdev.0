From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: 2.6.24.7 ipv6 send redirect
Date: Mon, 10 Nov 2008 10:40:22 +0200
Message-ID: <b25312890811100040rc3692efn9a6f5be7a0a9e814@mail.gmail.com>
References: <49149400.2060301@santabarbaralabs.com>
	 <200811101017.56235.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ext Roman Chertov" <roman@santabarbaralabs.com>,
	netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?="
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:48847 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881AbYKJIkX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 03:40:23 -0500
Received: by rv-out-0506.google.com with SMTP id k40so2362717rvb.1
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2008 00:40:22 -0800 (PST)
In-Reply-To: <200811101017.56235.remi.denis-courmont@nokia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

1)  There is no way to disable IPv6 ICMP redirect **sending ** messages=
=2E
You can only disable IPv6 ICMP redirect ** receiving** messages, via:
echo "0" > /proc/sys/net/ipv6/conf/all/accept_redirects

(Taking a brief look in the implementation will show that there
is a field named "accept_redirects" in ipv6_devconf structure,
but there is **no** field named send_redirects ,as in ipv4;
see: include/linux/ipv6.h.)

2) The RFC (rfc4294) says: (=A74.2)
" Redirect functionality SHOULD be supported.  If the node is  a
router, Redirect functionality MUST be supported."


Regards,
Rami Rosen


On Mon, Nov 10, 2008 at 10:17 AM, R=E9mi Denis-Courmont
<remi.denis-courmont@nokia.com> wrote:
> On Friday 07 November 2008 21:16:16 ext Roman Chertov, you wrote:
>>     I need to disable IPv6 ICMP redirect messages.  In the
>> /proc/sys/net/ipv4/conf/all/ there is a flag send_redirects which
>> disables sending of the redirects in IPv4.  However, this option is =
not
>> present in the /proc/sys/net/ipv6/conf/all/.  Did this option get mo=
ved
>> to another location?  I would prefer to disable the redirects via a =
flag
>> and want to resort to changing the IPv6 forwarding code as the last
>> measure.
>
> In my understanding, disabling redirects on an IPv6 router is not all=
owed by
> the specification (see RFC4294 =A74.2).
>
> --
> R=E9mi Denis-Courmont
> Maemo Software, Nokia Devices R&D
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
